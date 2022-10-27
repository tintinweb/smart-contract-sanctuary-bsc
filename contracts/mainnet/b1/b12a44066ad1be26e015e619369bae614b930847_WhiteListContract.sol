/**
 *Submitted for verification at BscScan.com on 2022-10-27
*/

// SPDX-License-Identifier: MIT
pragma solidity = 0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface nftStaking {
    function userStakingNumList(address _user) external view returns (uint256);
}

interface erc721Token {
    function balanceOf(address _user) external view returns (uint256);
}

interface erc20Token {
    function balanceOf(address _user) external view returns (uint256);
}

contract WhiteListContract is Ownable {
    nftStaking[] public nftStakingList;
    erc721Token[] public erc721TokenList;
    erc20Token[] public erc20TokenList;
    mapping(erc20Token=>uint256) public minAmountList;

    function setNftStakingList(nftStaking[] memory _nftStakingList) external onlyOwner {
        nftStakingList = _nftStakingList;
    }

     function setErc721TokenList(erc721Token[] memory _erc721TokenList) external onlyOwner {
        erc721TokenList = _erc721TokenList;
    }

    function setErc20TokenList(erc20Token[] memory _erc20TokenList) external onlyOwner {
        erc20TokenList = _erc20TokenList;
    }

    function setMinAmountList(erc20Token[] memory _erc20TokenList,uint256[] memory _minAmountList) external onlyOwner {
        require(_erc20TokenList.length == _minAmountList.length, "e001");
        for (uint256 i=0;i<_erc20TokenList.length;i++) {
            minAmountList[_erc20TokenList[i]] = _minAmountList[i];
        }
    }

    function getAllContract() external view returns (nftStaking[] memory, erc721Token[] memory ,erc20Token[] memory,uint256[] memory) {
        uint256[] memory x = new uint256[](erc20TokenList.length);
        for (uint256 i=0;i<erc20TokenList.length;i++) {
            x[i] = minAmountList[erc20TokenList[i]];
        }
        return (nftStakingList, erc721TokenList, erc20TokenList, x);
    }

    function isInWhiteList(address _user) external view returns (bool) {
        for (uint256 i=0;i<nftStakingList.length;i++) {
            if (nftStakingList[i].userStakingNumList(_user)>0) {
                return true;
            }
        }
        for (uint256 i=0;i<erc721TokenList.length;i++) {
            if (erc721TokenList[i].balanceOf(_user)>0) {
                return true;
            }
        }
        for (uint256 i=0;i<erc20TokenList.length;i++) {
            if (erc20TokenList[i].balanceOf(_user)>=minAmountList[erc20TokenList[i]]) {
                return true;
            }
        }
        return false;
    }
}