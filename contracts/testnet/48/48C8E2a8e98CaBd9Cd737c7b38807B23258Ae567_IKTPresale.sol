/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract IKTPresale is Ownable {
    event BuySuccess(address buyer, uint256 amount);

    IBEP20 BUSD = IBEP20(0x026c5CEFf055cB04F10138dF96E3B4Ae19fB1167);

    bool onSale = false;

    // package silver: 100 - amount 1000$
    // package gold: 150 - amount 2000$
    // package titan: 180 - amount 5000$
    // package platinum: 60 - amount 10000$
    // package diamond: 20 - amount 15000$
    address[] public buyerIndex;
    mapping (address => uint256) public buyers;
    uint256 public totalDeposit = 0;

    uint256 public silverRemain = 100;
    uint256 public silverAmount = 1000 * 1e18;

    uint256 public goldRemain = 150;
    uint256 public goldAmount = 2000 * 1e18;

    uint256 public titanRemain = 180;
    uint256 public titanAmount = 5000 * 1e18;

    uint256 public platinumRemain = 60;
    uint256 public platinumAmount = 10000 * 1e18;

    uint256 public diamondRemain = 20;
    uint256 public diamondAmount = 15000 * 1e18;

    modifier open() {
        require(onSale, "Not Open");
        _;
    }

    function openSale() external onlyOwner {
        onSale = true;
    }

    function closeSale() external onlyOwner {
        onSale = false;
    }

    function getBuyers(uint256 from, uint256 to) public view returns(address[] memory){
        address[] memory results;
        for (uint i = from; i < to; i++) {
            results[i - from] = buyerIndex[i];
        }
        return results;
    }

    function silverBuy() external open {
        // require busd balance > silver amount
        require(BUSD.balanceOf(_msgSender()) >= silverAmount, "Not enough balance BUSD");
        // require approve balance > silver amount
        require(BUSD.allowance(_msgSender(), address(this)) >= silverAmount, "Not enough allownance");
        // transfer busd from sender to this
        require(BUSD.transferFrom(_msgSender(), owner(), silverAmount), "Transfer failed");
        // add to list index
        if (buyers[_msgSender()] == 0) {
            buyerIndex.push(_msgSender());
        }
        // record sender total deposit
        buyers[_msgSender()] += silverAmount;
        // decrease remain package
        silverRemain--;
        // total deposit
        totalDeposit += silverAmount;

        emit BuySuccess(_msgSender(), silverAmount);
    }

    function goldBuy() external open {
        // require busd balance > gold amount
        require(BUSD.balanceOf(_msgSender()) >= goldAmount, "Not enough balance BUSD");
        // require approve balance > gold amount
        require(BUSD.allowance(_msgSender(), address(this)) >= goldAmount, "Not enough allownance");
        // transfer busd from sender to this
        require(BUSD.transferFrom(_msgSender(), owner(), goldAmount), "Transfer failed");
        // add to list index
        if (buyers[_msgSender()] == 0) {
            buyerIndex.push(_msgSender());
        }
        // record sender total deposit
        buyers[_msgSender()] += goldAmount;
        // decrease remain package
        goldRemain--;
        // total deposit
        totalDeposit += goldAmount;

        emit BuySuccess(_msgSender(), goldAmount);
    }

    function titanBuy() external open {
        // require busd balance > titan amount
        require(BUSD.balanceOf(_msgSender()) >= titanAmount, "Not enough balance BUSD");
        // require approve balance > titan amount
        require(BUSD.allowance(_msgSender(), address(this)) >= titanAmount, "Not enough allownance");
        // transfer busd from sender to this
        require(BUSD.transferFrom(_msgSender(), owner(), titanAmount), "Transfer failed");
        // add to list index
        if (buyers[_msgSender()] == 0) {
            buyerIndex.push(_msgSender());
        }
        // record sender total deposit
        buyers[_msgSender()] += titanAmount;
        // decrease remain package
        titanRemain--;
        // total deposit
        totalDeposit += titanAmount;

        emit BuySuccess(_msgSender(), titanAmount);
    }

    function platinumBuy() external open {
        // require busd balance > platinum amount
        require(BUSD.balanceOf(_msgSender()) >= platinumAmount, "Not enough balance BUSD");
        // require approve balance > platinum amount
        require(BUSD.allowance(_msgSender(), address(this)) >= platinumAmount, "Not enough allownance");
        // transfer busd from sender to this
        require(BUSD.transferFrom(_msgSender(), owner(), platinumAmount), "Transfer failed");
        // add to list index
        if (buyers[_msgSender()] == 0) {
            buyerIndex.push(_msgSender());
        }
        // record sender total deposit
        buyers[_msgSender()] += platinumAmount;
        // decrease remain package
        platinumRemain--;
        // total deposit
        totalDeposit += platinumAmount;

        emit BuySuccess(_msgSender(), platinumAmount);
    }

    function diamondBuy() external open {
        // require busd balance > diamond amount
        require(BUSD.balanceOf(_msgSender()) >= diamondAmount, "Not enough balance BUSD");
        // require approve balance > diamond amount
        require(BUSD.allowance(_msgSender(), address(this)) >= diamondAmount, "Not enough allownance");
        // transfer busd from sender to this
        require(BUSD.transferFrom(_msgSender(), owner(), diamondAmount), "Transfer failed");
        // add to list index
        if (buyers[_msgSender()] == 0) {
            buyerIndex.push(_msgSender());
        }
        // record sender total deposit
        buyers[_msgSender()] += diamondAmount;
        // decrease remain package
        diamondRemain--;
        // total deposit
        totalDeposit += diamondAmount;

        emit BuySuccess(_msgSender(), diamondAmount);
    }

    function withdrawToken(address token, uint256 amount) external onlyOwner { 
        IBEP20(token).transfer(owner(), amount);
    }

    function withdraw(uint256 amount) external onlyOwner {
        payable(owner()).transfer(amount);
    }
}