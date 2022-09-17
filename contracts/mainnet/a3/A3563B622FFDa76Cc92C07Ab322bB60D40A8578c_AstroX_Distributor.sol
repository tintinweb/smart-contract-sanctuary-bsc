/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

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

abstract contract IERC20 {
    function totalSupply() external view virtual returns (uint);

    function balanceOf(address account) external view virtual returns (uint);

    function transfer(address recipient, uint amount) external virtual returns (bool);

    function allowance(address owner, address spender) external view virtual returns (uint);

    function approve(address spender, uint amount) external virtual returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external virtual returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract AstroX_Distributor is Ownable {
    struct Tier {
        address payable _sAdr;
        uint256 _sThr;
    }
    struct Percs {
        uint256 tier1;
        uint256 tier2;
        uint256 tier3;
        uint256 tier4;
    }

    Tier[] tier1;
    Tier[] tier2;
    Tier[] tier3;
    Tier[] tier4;

    Percs public percs = Percs(50, 30, 15, 5);

    address token = 0xa839BC9882b5D994649ab69fe4D7290204677F40;

    function distribute() external onlyOwner {
        uint256 pool = address(this).balance;
        // Tier 1
        for(uint i=0; i< tier1.length; i++) {
            uint256 threshold = tier1[i]._sThr;
            address adr = tier1[i]._sAdr;
            if(IERC20(token).balanceOf(adr) < threshold) {
                tier1[i] = tier1[tier1.length - 1];
                tier1.pop();
            }
        }
        for(uint i=0; i< tier1.length; i++) {
            uint256 toReward = (pool * percs.tier1 / 100) / tier1.length;
            address payable adr = tier1[i]._sAdr;
            adr.transfer(toReward);
        }
        // Tier 2
        for(uint i=0; i< tier2.length; i++) {
            uint256 threshold = tier2[i]._sThr;
            address adr = tier2[i]._sAdr;
            if(IERC20(token).balanceOf(adr) < threshold) {
                tier2[i] = tier2[tier2.length - 1];
                tier2.pop();
            }
        }
        for(uint i=0; i< tier2.length; i++) {
            uint256 toReward = (pool * percs.tier2 / 100) / tier2.length;
            address payable adr = tier2[i]._sAdr;
            uint256 threshold = tier2[i]._sThr;
            if(IERC20(token).balanceOf(adr) >= threshold) {
                adr.transfer(toReward);
            }
        }
        // Tier 3
        for(uint i=0; i< tier3.length; i++) {
            uint256 threshold = tier3[i]._sThr;
            address adr = tier3[i]._sAdr;
            if(IERC20(token).balanceOf(adr) < threshold) {
                tier3[i] = tier3[tier3.length - 1];
                tier3.pop();
            }
        }
        for(uint i=0; i< tier3.length; i++) {
            uint256 toReward = (pool * percs.tier3 / 100) / tier3.length;
            address payable adr = tier3[i]._sAdr;
            uint256 threshold = tier3[i]._sThr;
            if(IERC20(token).balanceOf(adr) >= threshold) {
                adr.transfer(toReward);
            }
        }
        // Tier 4
        for(uint i=0; i< tier4.length; i++) {
            uint256 threshold = tier4[i]._sThr;
            address adr = tier4[i]._sAdr;
            if(IERC20(token).balanceOf(adr) < threshold) {
                tier4[i] = tier4[tier4.length - 1];
                tier4.pop();
            }
        }
        for(uint i=0; i< tier4.length; i++) {
            uint256 toReward = (pool * percs.tier4 / 100) / tier4.length;
            address payable adr = tier4[i]._sAdr;
            uint256 threshold = tier4[i]._sThr;
            if(IERC20(token).balanceOf(adr) >= threshold) {
                adr.transfer(toReward);
            }
        }
    }

    function adjustPercs(uint256 _tier1, uint256 _tier2, uint256 _tier3, uint256 _tier4) external onlyOwner {
        percs = Percs(_tier1, _tier2, _tier3, _tier4);
    }

    function importTiers(uint256 _tier, address payable[] memory _adr, uint256[] memory _thr) external onlyOwner {
        if(_tier == 1) {
            delete tier1;
            for(uint i=0; i< _adr.length; i++) {
                tier1.push(Tier(_adr[i], _thr[i] * 10**18));
            }
        }
        if(_tier == 2) {
            delete tier2;
            for(uint i=0; i< _adr.length; i++) {
                tier2.push(Tier(_adr[i], _thr[i] * 10**18));
            }
        }
        if(_tier == 3) {
            delete tier3;
            for(uint i=0; i< _adr.length; i++) {
                tier3.push(Tier(_adr[i], _thr[i] * 10**18));
            }
        }
        if(_tier == 4) {
            delete tier4;
            for(uint i=0; i< _adr.length; i++) {
                tier4.push(Tier(_adr[i], _thr[i] * 10**18));
            }
        }
    }

    function adjustToken(address _token) external onlyOwner {
        token = _token;
    }

    function showTier(uint256 _tier) public view returns(Tier[] memory) {
        if(_tier == 1) {
            return tier1;
        } else if(_tier == 2) {
            return tier2;
        } else if(_tier == 3) {
            return tier3;
        } else {
            return tier4;
        }
    }

    function withdrawBNB() public onlyOwner  {
        require(address(this).balance > 0, "Balance is 0");
        payable(owner()).transfer(address(this).balance);
    }

    receive() external payable {}
}