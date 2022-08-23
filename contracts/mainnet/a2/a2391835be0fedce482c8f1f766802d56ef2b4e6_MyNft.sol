//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC1155.sol";
import "./Ownable.sol";
import "./Strings.sol";
import "./SafeMath.sol" ;


interface IERC20 {

    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface AgentContract {

    function recordNftBurn(uint256 tokenId, address from, uint256 num) external;
}

interface UsdtContract {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract MyNft is Ownable, ERC1155 {
    using Strings for uint256;
    using SafeMath for uint256;

    string public name;
    string public symbol;
    string public baseURL;
    uint public maximumSalesNum = 2500;
    uint public maximumPurchase = 5;
    uint public nftPrice = 200;
    uint public totalSalesNum;
    address public beneficiary = 0xd6E31Cb883E46bFdE04096E8ac9E20aBacDAEBd6;
    address public usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
    mapping(address => bool) public minters;
    mapping(address => uint) public buyers;
    address public whitelist;
    
    event nftBuy(uint256 payAmount);

    modifier onlyMinter() {
        require(minters[_msgSender()], "Mint: caller is not the minter");
        _;
    }

    constructor(string memory url_, string memory name_, string memory symbol_) ERC1155(url_) {
        name = name_;
        symbol = symbol_;
        baseURL = url_;
        minters[_msgSender()] = true;
        whitelist = _msgSender();
    }

    function mint(address to_, uint256 tokenId_, uint num_) public onlyMinter returns (bool) {
        require(num_ > 0, "mint number err");
        _mint(to_, tokenId_, num_, "");
        return true;
    }

    function mintBatch(address to_, uint[] memory tokenIds_, uint256[] memory nums_) public onlyMinter returns (bool) {
        require(tokenIds_.length == nums_.length, "array length unequal");
        _mintBatch(to_, tokenIds_, nums_, "");
        return true;
    }

    function buy(uint256 tokenId_, uint num_) public returns (bool) {
        require(totalSalesNum + num_ <= maximumSalesNum, "maximum sales quantity has been reached");
        if(msg.sender == whitelist) {  
            _mint(msg.sender, tokenId_, num_, "");
            totalSalesNum += num_;
        } else {
            uint256 price = nftPrice * 10 ** 18;
            uint256 payAmount = price * num_;
            //require(msg.value >= price * num_, "price err");
            require(tokenId_ > 0, "tokenId err");
            require(num_ > 0, "mint number err");
            require(buyers[msg.sender] + num_ <= maximumPurchase, "maximum purchase quantity has been reached");
            UsdtContract(usdtAddress).transferFrom(msg.sender, address(this), payAmount);
            _mint(msg.sender, tokenId_, num_, "");
            buyers[msg.sender] += num_;
            totalSalesNum += num_;
            emit nftBuy(payAmount);
        }
        return true;
    }

    function setMaximumSalesNum(uint maximumSalesNum_) public onlyMinter {
        maximumSalesNum = maximumSalesNum_;
    }

    function setMaximumPurchase(uint maximumPurchase_) public onlyMinter {
        maximumPurchase = maximumPurchase_;
    }

    function setNftPrice(uint price_) public onlyMinter {
        nftPrice = price_;
    }

    function withdraw() public onlyMinter {
        uint256 balance = UsdtContract(usdtAddress).balanceOf(address(this));
        UsdtContract(usdtAddress).transfer(beneficiary, balance);
    }

    function setBeneficiary(address beneficiary_) public onlyMinter {
        beneficiary = beneficiary_;
    }

    function setWhitelist(address newAddr_) public onlyMinter {
        whitelist = newAddr_;
    }

}