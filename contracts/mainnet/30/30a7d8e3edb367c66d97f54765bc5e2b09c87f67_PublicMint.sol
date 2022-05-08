/*
This file is part of the MintMe project.

The MintMe Contract is free software: you can redistribute it and/or
modify it under the terms of the GNU lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The MintMe Contract is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the MintMe Contract. If not, see <http://www.gnu.org/licenses/>.

@author Ilya Svirin <[email protected]>
*/
// SPDX-License-Identifier: GNU lesser General Public License

pragma solidity ^0.8.0;

import "./mintme.sol";


contract PublicMint is Ownable
{
    using Address for address payable;

    address         public _mintme;
    address payable public _stakeholder;
    uint256         public _extraFeeWei;

    constructor ()
    {
        _stakeholder = payable(_msgSender());
    }

    function setExtraFee(uint256 extraFeeWei) public onlyOwner
    {
        _extraFeeWei = extraFeeWei;
    }

    function setMintMe(address mintme) public onlyOwner
    {
        // before or after this call the ownership of "mintme" contract
        // must be transferred to this contract
        _mintme = mintme;
    }

    function withdrawMintMe() public onlyOwner
    {
        require(_mintme != address(0), "PublicMint: nothing to withdraw");
        Ownable(_mintme).transferOwnership(_msgSender());
        _mintme = address(0);
    }

    function mint(address to, string memory contCID) public payable returns(uint256)
    {
        require(_mintme != address(0), "PublicMint: no mintme");
        if (_extraFeeWei != 0)
        {
            require(msg.value >= _extraFeeWei, "PublicMint: not enough funds");
            payable(owner()).sendValue(_extraFeeWei / 2);
            _stakeholder.sendValue(_extraFeeWei / 2);
        }
        return MintMe(_mintme).mint{value: msg.value - _extraFeeWei}(to, contCID);
    }
}