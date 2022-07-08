// SPDX-License-Identifier: AGPL-3.0-or-later

/// ProxyRegistry.sol

// Copyright (C) 2018-2021 Dai Foundation

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

pragma solidity >=0.5.0;
import "Interfaces.sol";

contract TargetERC20Transfer {
  function transferTokens(
    IERC20 token,
    uint256 amount,
    address to,
    address recipient
  ) external returns (address){
    // Transfer tokens from user to PRBProxy.
    // token.transferFrom(msg.sender, to, amount);

    // Transfer tokens from PRBProxy to specific recipient.
    // token.transfer(recipient, amount);
    return msg.sender;
  }
}

pragma solidity >=0.5.0;
interface IERC20{
    function transferFrom(address sender, address to, uint256 amount) external;

    function transfer(address recipient,uint256 amount) external;
}