// SPDX-License-Identifier: AGPL-3.0-or-later

/// vow.sol -- Hay settlement module

// Copyright (C) 2018 Rain <[email protected]>
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

pragma solidity ^0.8.10;

import "./interfaces/VatLike.sol";

contract Vow {
    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external auth { require(live == 1, "Vow/not-live"); wards[usr] = 1; }
    function deny(address usr) external auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "Vow/not-authorized");
        _;
    }

    // --- Data ---
    VatLike public vat;          // CDP Engine
    address public multisig;     // Surplus multisig

    mapping (uint256 => uint256) public sin;  // debt queue
    uint256 public Sin;   // Queued debt            [rad]
    uint256 public Ash;   // On-auction debt        [rad]

    uint256 public hump;  // Surplus buffer         [rad]

    uint256 public lever; // 0-Multisig,

    uint256 public live;  // Active Flag

    // --- Init ---
    constructor(address vat_, address multisig_) {
        wards[msg.sender] = 1;
        vat     = VatLike(vat_);
        multisig = multisig_;
        live = 1;
    }

    // --- Math ---
    function add(uint x, uint y) internal pure returns (uint z) {
        unchecked {
            require((z = x + y) >= x);
        }
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        unchecked {
            require((z = x - y) <= x);
        }
    }
    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }

    // --- Administration ---
    function file(bytes32 what, uint data) external auth {
        if (what == "hump") hump = data;
        else if (what == "lever") lever = data;
        else revert("Vow/file-unrecognized-param");
    }

    function file(bytes32 what, address data) external auth {
        if (what == "multisig") multisig = data;
        else revert("Vow/file-unrecognized-param");
    }

    // Debt settlement
    function heal(uint rad) external {
        require(rad <= vat.hay(address(this)), "Vow/insufficient-surplus");
        require(rad <= sub(sub(vat.sin(address(this)), Sin), Ash), "Vow/insufficient-debt");
        vat.heal(rad);
    }
    function kiss(uint rad) external {
        require(rad <= Ash, "Vow/not-enough-ash");
        require(rad <= vat.hay(address(this)), "Vow/insufficient-surplus");
        Ash = sub(Ash, rad);
        vat.heal(rad);
    }

    function cage() external auth {
        require(live == 1, "Vow/not-live");
        live = 0;
        Sin = 0;
        Ash = 0;
        vat.heal(min(vat.hay(address(this)), vat.sin(address(this))));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface VatLike {
    function init(bytes32 ilk) external;

    function hope(address usr) external;

    function nope(address usr) external;

    function rely(address usr) external;

    function deny(address usr) external;

    function move(address src, address dst, uint256 rad) external;

    function behalf(address bit, address usr) external;

    function frob(bytes32 i, address u, address v, address w, int dink, int dart) external;

    function flux(bytes32 ilk, address src, address dst, uint256 wad) external;

    function ilks(bytes32) external view returns (uint256, uint256, uint256, uint256, uint256);

    function fold(bytes32 i, address u, int rate) external;

    function gem(bytes32, address) external view returns (uint256);

    function hay(address) external view returns (uint256);

    function urns(bytes32, address) external view returns (uint256, uint256);

    function file(bytes32, bytes32, uint) external;

    function sin(address) external view returns (uint256);

    function heal(uint rad) external;

    function suck(address u, address v, uint rad) external;
}