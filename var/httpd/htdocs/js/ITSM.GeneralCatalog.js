// --
// OTOBO is a web-based ticketing system for service organisations.
// --
// Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
// Copyright (C) 2019-2024 Rother OSS GmbH, https://otobo.io/
// --
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.
// --

"use strict";

var ITSM = ITSM || {};

/**
 * @namespace GeneralCatalog
 * @author Rother OSS GmbH
 * @description
 *      This namespace contains the special module function for General Catalog.
 */
 ITSM.GeneralCatalog = (function (TargetNS) {

    /**
     * @name Init
     * @memberof GeneralCatalog
     * @function
     * @description
     *      This function initializes actions for General Catalog.
     */
    TargetNS.Init = function() {

        // init checkbox to include invalid elements
        $('input#IncludeInvalid').off('change').on('change', function () {
            var URL = Core.Config.Get("Baselink") + 'Action=' + Core.Config.Get("Action") + ';Subaction=ItemList;Class=' + $('[name="Class"]').val() + ';IncludeInvalid=' + ( $(this).is(':checked') ? 1 : 0 );
            window.location.href = URL;
        });

        if (typeof Core.Config.Get('WarningIncidentState') !== 'undefined'
            && parseInt(Core.Config.Get('WarningIncidentState'), 10) === 1
        ) {
            $('#Submit').click(function(Event){
                var Functionality = $('#Functionality').val(),
                    ValidID       = $('#ValidID').val();

                Event.preventDefault();

                if (Functionality === 'warning' && ValidID != '1') {
                    Core.UI.Dialog.ShowDialog({
                        Modal: true,
                        Title: Core.Language.Translate('Warning'),
                        HTML: '<p>' + Core.Language.Translate('Warning incident state can not be set to invalid.') + '</p>',
                        PositionTop: '15%',
                        PositionLeft: 'Center',
                        CloseOnEscape: false,
                        CloseOnClickOutside: false,
                        Buttons: [
                            {
                                Label: Core.Language.Translate('Cancel'),
                                Function: function () {
                                    Core.UI.Dialog.CloseDialog($('.Dialog:visible'));
                                }
                            },
                        ]
                    });

                }
                else {
                    $(this).closest('form').trigger('submit');
                }
            });
        }
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(ITSM.GeneralCatalog || {}));
