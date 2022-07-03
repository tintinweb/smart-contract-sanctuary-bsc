/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    function getHoldsLength() external view returns(uint256);
    function getHoldsAddress(uint256 _index) external view returns(address);
}

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
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract GMTReward is Context, Ownable {
    using SafeMath for uint256;

    address[] public communityAddr;
    address[] public superNodeAddr;
    address[] public marketingAddr;
    mapping(address => bool) community;
    mapping(address => bool) superNode;
    mapping(address => bool) marketing;
    IERC20 gmt;

    constructor() public {
        gmt = IERC20(0x2bA716188d5F8718e4e5Aa97F617ABb45A3D3Fb7);
    }

    function getCommunityAddrNum() external view returns (uint256) {
        return communityAddr.length;
    }

    function getSuperNodeAddrNum() external view returns (uint256) {
        return superNodeAddr.length;
    }

    function getMarketingAddrNum() external view returns (uint256) {
        return marketingAddr.length;
    }

    function setGmt (address _contract) external onlyOwner {
        gmt = IERC20(_contract);
    }

    function takeReward () external {
        uint256 balance = gmt.balanceOf(address(this));
        require(balance > 0, "Reward amount must be greater than zero");

        uint256 marketingFee = balance.mul(3).div(15);
        uint256 communityRewardFee = balance.mul(5).div(15);
        uint256 superNodeFee = balance.sub(marketingFee).sub(communityRewardFee);
        _takeMarketingReward(marketingFee);
        _takeCommunityReward(communityRewardFee);
        _takeSuperNodeReward(superNodeFee);
    }

    function setSuperNodeAddr (address account, bool state) public onlyOwner {
        if (state) {
            superNode[account] = state;
            (bool isExist,) = searchSuperNode(account);

            if (!isExist) {
                superNodeAddr.push(account);
            }
            
        } else {
            superNode[account] = state;
            (bool isExist, uint256 index) = searchSuperNode(account);
            if (isExist) {
                removeSuperNode(index);
            }
        }
        
    }

    function setCommunityAddr (address account, bool state) public onlyOwner {
        if (state) {
            community[account] = state;
            (bool isExist,) = searchCommunity(account);

            if (!isExist) {
                communityAddr.push(account);
            }
            
        } else {
            community[account] = state;
            (bool isExist, uint256 index) = searchCommunity(account);
            if (isExist) {
                removeCommunity(index);
            }
        }
        
    }

    function setMarketingAddr (address account, bool state) public onlyOwner {
        if (state) {
            marketing[account] = state;
            (bool isExist,) = searchMarketing(account);

            if (!isExist) {
                marketingAddr.push(account);
            }
            
        } else {
            marketing[account] = state;
            (bool isExist, uint256 index) = searchMarketing(account);
            if (isExist) {
                removeMarketingAddr(index);
            }
        }
        
    }

    function searchSuperNode (address account) private view returns (bool isExist, uint256 index) {
        for (uint256 i = 0; i < superNodeAddr.length; i++) {
            if (superNodeAddr[i] == account) {
                isExist = true;
                index = i;
            }
        }
    }

    function searchCommunity (address account) private view returns (bool isExist, uint256 index) {
        for (uint256 i = 0; i < communityAddr.length; i++) {
            if (communityAddr[i] == account) {
                isExist = true;
                index = i;
            }
        }
    }

    function searchMarketing (address account) private view returns (bool isExist, uint256 index) {
        for (uint256 i = 0; i < marketingAddr.length; i++) {
            if (marketingAddr[i] == account) {
                isExist = true;
                index = i;
            }
        }
    }

    function removeSuperNode(uint256 index) private {
        superNodeAddr[index] = superNodeAddr[superNodeAddr.length - 1];
        superNodeAddr.pop();
    }

    function removeCommunity (uint256 index) private {
        communityAddr[index] = communityAddr[communityAddr.length - 1];
        communityAddr.pop();
    }

    function removeMarketingAddr(uint256 index) private {
        marketingAddr[index] = marketingAddr[marketingAddr.length - 1];
        marketingAddr.pop();
    }

    function _takeCommunityReward (
        uint256 communityRewardFee
    ) private {
        if (communityRewardFee == 0) return;

        uint256 communityRewardAmount = communityRewardFee.div(communityAddr.length);
        for (uint256 i = 0; i < communityAddr.length; i++) {
            if (i == communityAddr.length.sub(1)) {
                communityRewardAmount = communityRewardFee.sub((communityAddr.length.sub(1)).mul(communityRewardAmount));
                gmt.transfer(communityAddr[i], communityRewardAmount);
            } else {
                gmt.transfer(communityAddr[i], communityRewardAmount);
            }
            
        }
    }

    function _takeSuperNodeReward (
        uint256 superNodeFee
    ) private {
        if (superNodeFee == 0) return;

        uint256 superNodeFeeAmount = superNodeFee.div(superNodeAddr.length);
        for (uint256 i = 0; i < superNodeAddr.length; i++) {
            if (i == superNodeAddr.length.sub(1)) {
                superNodeFeeAmount = superNodeFee.sub((superNodeAddr.length.sub(1)).mul(superNodeFeeAmount));
                gmt.transfer(superNodeAddr[i], superNodeFeeAmount);
            } else {
                gmt.transfer(superNodeAddr[i], superNodeFeeAmount);
            }
            
        }
    }

    function _takeMarketingReward (
        uint256 marketingFee
    ) private {
        if (marketingFee == 0) return;

        uint256 marketingFeeAmount = marketingFee.div(marketingAddr.length);
        for (uint256 i = 0; i < marketingAddr.length; i++) {
            if (i == marketingAddr.length.sub(1)) {
                marketingFeeAmount = marketingFee.sub((marketingAddr.length.sub(1)).mul(marketingFeeAmount));
                gmt.transfer(marketingAddr[i], marketingFeeAmount);
            } else {
                gmt.transfer(marketingAddr[i], marketingFeeAmount);
            }
            
        }
    }

    function setErc20With(
        address con,
        address addr,
        uint256 amount
    ) external onlyOwner {
        IERC20(con).transfer(addr, amount);
    }
}