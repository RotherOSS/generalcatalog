# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2026 Rother OSS GmbH, https://otobo.io/
# --
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# --

use v5.24;
use strict;
use warnings;
use utf8;

# core modules

# CPAN modules
use Test2::V0 qw( done_testing is ok );

# OTOBO modules
use Kernel::System::UnitTest::RegisterDriver;    # Set up $Kernel::OM
use Kernel::System::UnitTest::Selenium;

my $Selenium = Kernel::System::UnitTest::Selenium->new( LogExecuteCommandActive => 1 );

$Selenium->RunTest(
    sub {

        my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

        # Create and log in test user.
        my $TestUserLogin = $Helper->TestUserCreate(
            Groups => ['admin'],
        ) || die "Did not get test user";

        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        my $ScriptAlias = $Kernel::OM->Get('Kernel::Config')->Get('ScriptAlias');

        # Navigate to AdminGeneralCatalog screen.
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AdminGeneralCatalog");

        # Click "Add Catalog Class".
        $Selenium->find_element("//button[\@value='Add'][\@type='submit']")->VerifiedClick();

        # Check for input fields.
        for my $ID (
            qw(ClassDsc Name ValidID Comment)
            )
        {
            my $Element = $Selenium->find_element( "#$ID", 'css' );
            $Element->is_enabled();
            $Element->is_displayed();
        }

        # Check client side validation.
        $Selenium->find_element( "#Name",   'css' )->clear();
        $Selenium->find_element( "#Submit", 'css' )->click();
        $Selenium->WaitFor( JavaScript => 'return $("#Name.Error").length' );

        is(
            $Selenium->execute_script(
                "return \$('#Name').hasClass('Error')"
            ),
            '1',
            'Client side validation correctly detected missing input value',
        );

        # Create real test catalog class.
        my $CatalogClassDsc  = "CatalogClassDsc" . $Helper->GetRandomID();
        my $CatalogClassName = "CatalogClassName" . $Helper->GetRandomID();
        $Selenium->find_element( "#ClassDsc", 'css' )->send_keys($CatalogClassDsc);
        $Selenium->find_element( "#Name",     'css' )->send_keys($CatalogClassName);
        $Selenium->find_element( "#Comment",  'css' )->send_keys("Selenium catalog class");
        $Selenium->execute_script("\$('#ValidID').val('1').trigger('redraw.InputField').trigger('change');");
        $Selenium->find_element( '#Submit', 'css' )->VerifiedClick();

        # Click "Go to overview".
        $Selenium->find_element("//a[contains(\@href, \'Action=AdminGeneralCatalog' )]")->VerifiedClick();

        # Check for created test catalog class in AdminGeneralCatalog screen and click on it.
        $Selenium->content_contains(
            $CatalogClassDsc,
            "Created test catalog class $CatalogClassDsc - found",
        );
        $Selenium->find_element(
            "//a[contains(\@href, \'Action=AdminGeneralCatalog;Subaction=ItemList;Class=$CatalogClassDsc' )]"
        )->VerifiedClick();

        # Click "Add Catalog Item".
        $Selenium->find_element("//button[\@value='Add'][\@type='submit']")->VerifiedClick();

        # Check client side validation.
        $Selenium->find_element( "#Name",   'css' )->clear();
        $Selenium->find_element( "#Submit", 'css' )->click();
        $Selenium->WaitFor( JavaScript => 'return $("#Name.Error").length' );

        is(
            $Selenium->execute_script(
                "return \$('#Name').hasClass('Error')"
            ),
            '1',
            'Client side validation correctly detected missing input value',
        );

        # Try to create catalog item that already exists.
        $Selenium->find_element( "#Name", 'css' )->send_keys($CatalogClassName);
        $Selenium->find_element("//button[\@value='Submit'][\@type='submit']")->VerifiedClick();

        # Verify error message.
        $Selenium->content_contains(
            'Can\'t add new item! General catalog item with same name already exists in this class.',
            "Error message - displayed",
        );

        # Return back to test catalog class screen and click on "Add Catalog Item".
        $Selenium->VerifiedGet(
            "${ScriptAlias}index.pl?Action=AdminGeneralCatalog;Subaction=ItemList;Class=$CatalogClassDsc"
        );
        $Selenium->find_element("//button[\@value='Add'][\@type='submit']")->VerifiedClick();

        # Create real test catalog item.
        my $CatalogClassItem = "CatalogClassItem" . $Helper->GetRandomID();
        $Selenium->find_element( "#Name",    'css' )->send_keys($CatalogClassItem);
        $Selenium->find_element( "#Comment", 'css' )->send_keys("Selenium catalog item");
        $Selenium->execute_script("\$('#ValidID').val('1').trigger('redraw.InputField').trigger('change');");
        $Selenium->find_element("//button[\@value='Submit'][\@type='submit']")->VerifiedClick();

        # Get test catalog items IDs.
        my @CatalogItemIDs;
        for my $CatalogItems ( $CatalogClassName, $CatalogClassItem ) {
            my $CatalogClassItemData = $Kernel::OM->Get('Kernel::System::GeneralCatalog')->ItemGet(
                Class => $CatalogClassDsc,
                Name  => $CatalogItems,
            );
            my $CatalogItemID = $CatalogClassItemData->{ItemID};
            push @CatalogItemIDs, $CatalogItemID;
        }

        # Check for created test catalog item and click on it.
        $Selenium->content_contains(
            $CatalogClassItem,
            "Created test catalog item $CatalogClassItem - found",
        );
        $Selenium->find_element(
            "//a[contains(\@href, \'Action=AdminGeneralCatalog;Subaction=ItemEdit;ItemID=$CatalogItemIDs[1]' )]"
        )->VerifiedClick();

        # Check new test catalog item values.
        is(
            $Selenium->find_element( '#Name', 'css' )->get_value(),
            $CatalogClassItem,
            "#Name stored value",
        );
        is(
            $Selenium->find_element( '#Comment', 'css' )->get_value(),
            "Selenium catalog item",
            "#Comment stored value",
        );

        # Edit name and comment.
        my $EditCatalogClassItem = "Edit" . $CatalogClassItem;
        $Selenium->find_element( "#Name",    'css' )->clear();
        $Selenium->find_element( "#Name",    'css' )->send_keys($EditCatalogClassItem);
        $Selenium->find_element( "#Comment", 'css' )->send_keys(" edit");
        $Selenium->find_element("//button[\@value='Submit'][\@type='submit']")->VerifiedClick();

        # Check edited test catalog item values.
        $Selenium->find_element( $EditCatalogClassItem, 'link_text' )->VerifiedClick();
        is(
            $Selenium->find_element( '#Name', 'css' )->get_value(),
            $EditCatalogClassItem,
            "#Name updated value",
        );
        is(
            $Selenium->find_element( '#Comment', 'css' )->get_value(),
            "Selenium catalog item edit",
            "#Comment updated value",
        );

        # Click on 'cancel' and verify correct link.
        $Selenium->find_element( "Cancel", 'link_text' )->VerifiedClick();
        ok(
            $Selenium->find_element( $EditCatalogClassItem, 'link_text' ),
            "Cancel link is correct."
        );

        # Get WarningID. TODO: this works only when ITSMCore is already installed
        my $ItemDataRef = $Kernel::OM->Get('Kernel::System::GeneralCatalog')->ItemGet(
            Class => 'ITSM::Core::IncidentState',
            Name  => 'Warning',
        );
        my $WarningID = $ItemDataRef->{ItemID} // '';
        ok(
            $WarningID,
            "Warning incident state ID - $WarningID",
        );

        # Navigate to Warning edit screen.
        $Selenium->VerifiedGet(
            "${ScriptAlias}index.pl?Action=AdminGeneralCatalog;Subaction=ItemEdit;ItemID=$WarningID"
        );

        $Selenium->WaitFor(
            JavaScript => 'return typeof($) === "function" && $("#ValidID").length && $("#Functionality").length;'
        );

        # Select 'warning' as Functionality option.
        $Selenium->InputFieldValueSet(
            Element => '#Functionality',
            Value   => 'warning',
        );

        # Select 'Invalid' as ValidID option.
        $Selenium->InputFieldValueSet(
            Element => '#ValidID',
            Value   => '2',
        );

        $Selenium->WaitForjQueryEventBound(
            CSSSelector => '#SubmitAndContinue',
            Event       => 'click',
        );
        $Selenium->WaitForjQueryEventBound(
            CSSSelector => '#Submit',
            Event       => 'click',
        );

        # Click 'Save' and 'Save and finish'.
        for my $ButtonID (qw(SubmitAndContinue Submit)) {
            $Selenium->find_element( "#$ButtonID", 'css' )->click();

            $Selenium->WaitFor( JavaScript => 'return $(".Dialog:visible").length;' );

            my $WarningText = 'Warning incident state can not be set to invalid.';

            ok(
                $Selenium->execute_script("return \$('.Dialog:contains(\"$WarningText\")').length;"),
                "'$ButtonID' click - Warning dialog is found",
            );

            $Selenium->WaitForjQueryEventBound(
                CSSSelector => '#DialogButton1',
                Event       => 'click',
            );

            # Click the cancel button.
            $Selenium->find_element( '#DialogButton1', 'css' )->click();

            $Selenium->WaitFor( JavaScript => 'return !$(".Dialog:visible").length;' );
        }

        # Select 'Valid' as ValidID option.
        $Selenium->InputFieldValueSet(
            Element => '#ValidID',
            Value   => '1',
        );

        # Click Save.
        $Selenium->find_element( "#SubmitAndContinue", 'css' )->VerifiedClick();

        $Selenium->WaitFor(
            JavaScript => 'return typeof($) === "function" && $("#ValidID").length && $("#Functionality").length;'
        );

        ok(
            $Selenium->execute_script("return \$('#Functionality').val() == 'warning';"),
            "Incident State Type is set to 'warning'",
        );
        ok(
            $Selenium->execute_script("return \$('#ValidID').val() == '1';"),
            "ValidID is set to '1'",
        );

        my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

        # Delete created test catalog class.
        for my $CatalogItem (@CatalogItemIDs) {

            my $Success = $DBObject->Do(
                SQL  => "DELETE FROM general_catalog_preferences WHERE general_catalog_id = ?",
                Bind => [ \$CatalogItem ],
            );
            ok(
                $Success,
                "CatalogItemID $CatalogItem preference - deleted",
            );

            $Success = $DBObject->Do(
                SQL  => "DELETE FROM general_catalog WHERE id = ?",
                Bind => [ \$CatalogItem ],
            );
            ok(
                $Success,
                "CatalogItemID $CatalogItem - deleted",
            );
        }

        # Clean up cache.
        $Kernel::OM->Get('Kernel::System::Cache')->CleanUp( Type => 'GeneralCatalog' );
    }
);

done_testing;
