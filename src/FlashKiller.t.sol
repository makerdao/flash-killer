// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Copyright (C) 2022 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity ^0.8.11;

import "ds-test/test.sol";

import { FlashKiller } from "./FlashKiller.sol";

interface ChainLogLike {
    function getAddress(bytes32) external view returns (address);
}

interface EndLike {
    function cage() external;
}

interface Hevm {
    function store(address, bytes32, bytes32) external;
}

interface FlashLike {
    function wards(address) external view returns (uint256);
    function max() external view returns (uint256);
}

contract FlashKillerTest is DSTest {
    FlashKiller killer;
    Hevm hevm = Hevm(address(bytes20(uint160(uint256(keccak256('hevm cheat code'))))));

    address vat;
    address flash;

    ChainLogLike constant chainLog = ChainLogLike(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);

    function setUp() public {
        vat = chainLog.getAddress("MCD_VAT");
        flash = chainLog.getAddress("MCD_FLASH");
        killer = new FlashKiller(vat, flash);

        assertEq(address(killer.vat()), address(vat));
        assertEq(address(killer.flash()), address(flash));

        // Force permission from the vat to the killer
        hevm.store(
            flash,
            keccak256(abi.encode(address(killer), uint256(0))),
            bytes32(uint256(1))
        );
        assertEq(FlashLike(flash).wards(address(killer)), 1);
    }

    function _cage() internal {
        address end = chainLog.getAddress("MCD_END");
        // Get End auth to allow us to call cage()
        hevm.store(
            end,
            keccak256(abi.encode(address(this), uint256(0))),
            bytes32(uint256(1))
        );
        EndLike(end).cage();
    }

    function testKill() public {
        _cage();
        assertTrue(FlashLike(flash).max() > 0);
        killer.kill();
        assertEq(FlashLike(flash).max(), 0);
    }

    function testFailNotCaged() public {
        killer.kill();
    }
}
