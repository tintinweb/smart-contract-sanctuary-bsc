/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
abstract contract Ownable {

    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        require(initialOwner != address(0));
        _owner = initialOwner;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
 interface IERC20 {
     function transfer(address to, uint256 value) external returns (bool);
     function approve(address spender, uint256 value) external returns (bool);
     function transferFrom(address from, address to, uint256 value) external returns (bool);
     function totalSupply() external view returns (uint256);
     function balanceOf(address who) external view returns (uint256);
     function allowance(address owner, address spender) external view returns (uint256);
     function mint(address to, uint256 value) external returns (bool);
     function burnFrom(address from, uint256 value) external;
 }

 interface IERC721 {
     function balanceOf(address owner) external view returns (uint256 balance);
     function ownerOf(uint256 tokenId) external view returns (address owner);
     function safeTransferFrom(
         address from,
         address to,
         uint256 tokenId
     ) external;
     function transferFrom(
         address from,
         address to,
         uint256 tokenId
     ) external;
     function approve(address to, uint256 tokenId) external;
     function getApproved(uint256 tokenId) external view returns (address operator);
     function setApprovalForAll(address operator, bool _approved) external;
     function isApprovedForAll(address owner, address operator) external view returns (bool);
     function safeTransferFrom(
         address from,
         address to,
         uint256 tokenId,
         bytes calldata data
     ) external;
     function mint(address to) external returns(uint256);
     function burn(uint256 tokenId) external;
 }

/**
 * @title Sale contract
 */
contract Sale is Ownable {
    using SafeMath for uint256;

    IERC20 public USDT;
    IERC721 public NFT;

    struct User {
        address[] referrals;
        address referrer;
        uint256 totalBonuses;
        uint256 purchased;
    }

    mapping (address => User) public users;

    address public feeWallet;

    uint256 public price = 777e18;

    uint256[] public refPercents = [5, 10, 7, 5, 3];

    event RefBonus(address indexed account, address indexed referrer, uint256 level, uint256 amount);

    constructor(address USDTAddr, address NFTAddr, address initialOwner, address initialFeeWallet) Ownable(initialOwner) {
        require(USDTAddr != address(0) && NFTAddr != address(0) && initialFeeWallet != address(0));

        USDT = IERC20(USDTAddr);
        NFT = IERC721(NFTAddr);

        feeWallet = initialFeeWallet;
    }

    function buyNFT(address from, uint256 amount, address referrer) public returns(uint256[] memory) {
        if (users[from].referrer == address(0) && referrer != msg.sender) {
            users[from].referrer = referrer;
            users[referrer].referrals.push(from);
        }

        uint256 totalAmount = price * amount;
        USDT.transferFrom(from, address(this), totalAmount);

        uint256 refBonus;
        uint256 totalBonus;
        address acc = msg.sender;
        for (uint256 i; i < 5; i++) {
            if (users[acc].referrer != address(0)) {
                refBonus = totalAmount * refPercents[i] / 100;
                totalBonus += refBonus;
                USDT.transfer(users[acc].referrer, refBonus);
                users[users[acc].referrer].totalBonuses += refBonus;
                emit RefBonus(users[acc].referrer, from, i, refBonus);
                acc = users[acc].referrer;
            } else break;
        }

        USDT.transfer(feeWallet, totalAmount - totalBonus);

        users[from].purchased += amount;

        uint256[] memory ids = new uint256[](amount);
        for (uint256 i; i < amount; i++) {
            ids[i] = NFT.mint(from);
        }
        return ids;
    }

    function sendNFT(address account, uint256 amount) public onlyOwner returns(uint256[] memory)  {
        uint256[] memory ids = new uint256[](amount);
        for (uint256 i; i < amount; i++) {
            ids[i] = NFT.mint(account);
        }
        return ids;
    }

    function withdrawERC20(address ERC20Token, address recipient) external onlyOwner {

        uint256 amount = IERC20(ERC20Token).balanceOf(address(this));
        IERC20(ERC20Token).transfer(recipient, amount);

    }

    function changeFeeWallet(address newWallet) public onlyOwner {
        require(newWallet != address(0));
        feeWallet = newWallet;
    }

    function getReferrerInfo(address account) public view returns(address referrer, uint256 amountOfReferrals, uint256 totalBonuses) {
        referrer = users[account].referrer;
        amountOfReferrals = users[account].referrals.length;
        totalBonuses = users[account].totalBonuses;
    }

    function getReferralInfo(address account, uint256 from, uint256 to) public view returns(address[] memory referrals, uint256[] memory bonuses) {
        uint256 amountOfReferrals = users[account].referrals.length;

        if (to > amountOfReferrals) {
            to = amountOfReferrals;
        }

        require(to > from);

        uint256 length = to - from;

        referrals = new address[](length);
        bonuses = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            referrals[i] = users[account].referrals[from + i];
            bonuses[i] = users[referrals[from + i]].purchased * price * refPercents[0] / 100;
        }
    }

    function _bytesToAddress(bytes memory source) internal pure returns(address parsedreferrer) {
        assembly {
            parsedreferrer := mload(add(source,0x14))
        }
    }

}