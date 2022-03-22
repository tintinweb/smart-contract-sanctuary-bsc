/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMetaWarden {
    function balanceOf(address owner) external view returns (uint256 balance);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
}

contract TopMwadClass {
    IMetaWarden public immutable mwad;

    constructor (IMetaWarden _mwad) {
        mwad = _mwad;
    }

    function getTopOne(address _user)
        public
        view
        returns (uint256 _tokenId, uint256 _class, bool _found)
    {
        uint256 balance = mwad.balanceOf(_user);
        if (balance == 0) {
            return (0, 0, false);
        }

        _tokenId = 99_999;
        for (uint256 i = 0; i < balance; i++) {
            uint256 tmpId = mwad.tokenOfOwnerByIndex(_user, i);
            if (tmpId < _tokenId) {
                _tokenId = tmpId;
            }
        }

        // Golden
        if (_tokenId < 30) {
            _class = 0;

        // Super
        } else if (_tokenId < 330) {
            _class = 1;

        // Common
        } else {
            _class = 2;
        }

        return (_tokenId, _class, true);
    }
}