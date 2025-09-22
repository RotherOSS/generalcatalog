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
ITSM.GeneralCatalog = ITSM.GeneralCatalog || {};


/**
 * @namespace GeneralCatalog
 * @author Rother OSS GmbH
 * @description
 *      This namespace contains the special module function for the General Catalog Color Picker module.
 */
 ITSM.GeneralCatalog.JSColorPicker = (function (TargetNS) {

    /**
     * @name Init
     * @memberof GeneralCatalog.ColorPicker
     * @function
     * @description
     *      This function initializes actions for General Catalog.
     */
    TargetNS.Init = function() {

        /*global jscolor: true */
        jscolor.dir = Core.Config.Get('GeneralCatalog::Frontend::JSColorPickerPath');
        jscolor.bindClass = 'JSColorPicker';
        jscolor.install();
    };

    Core.Init.RegisterNamespace(TargetNS, 'CONFIG_LOADED');

    return TargetNS;
}(ITSM.GeneralCatalog.JSColorPicker || {}));
