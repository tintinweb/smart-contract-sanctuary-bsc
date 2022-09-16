/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Presale Rate in decimal 18

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

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() private onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) private onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

interface Token {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value);
}


contract ICOPrivateSale is Ownable {

    using SafeMath for uint256;

    event Print(string msg, uint256 stime, uint256 _etime);
    address public liquidityAddress;

    uint256 public presaleRate; // Sell PresaleRate (input PresaleRate should be multiply with 10 to the power 18)

    address public AqcTokenContractAddr; // SoldOut Token Contract Address
    address public USDTTokenContractAddr; // SoldOut Token Contract Address
    
    uint256 public TotalCollectedBNBFund;   


    address[]  SellTrackAddr; // capture all the addresses who perform trades
    uint256[]  SellTrackAddrAmount; // capture all the addresses amount who perform trades

    constructor(address _AqcTokenContractAddr, address _USDTContractAddress, uint256 _presaleRate, address _liquidityAddr) {  
        USDTTokenContractAddr = _USDTContractAddress;
        AqcTokenContractAddr = _AqcTokenContractAddr;
        presaleRate = _presaleRate; // Presale Rate in decimal 9
        liquidityAddress = _liquidityAddr;
        }

    
 // SaleICOToken function that will use to sell the SoldOut Token
    function SaleICOToken(uint256 _usdtAmount) public returns (bool) {
        require((_usdtAmount)/presaleRate >= 100,"Token Buy less than 100 not allowed.");
        require(AQCBalance() >= (_usdtAmount)/presaleRate, "Insufficient funds on ICO");

        uint256 totalToken = (_usdtAmount)/presaleRate;
        uint256 _usdtAmountAfterFee = _usdtAmount + (_usdtAmount*3)/100;

        // Collect USDT to ICO Contract Address
        Token(USDTTokenContractAddr).transferFrom(msg.sender, address(this), _usdtAmountAfterFee);
        // Transfer AQC to admin 
        Token(AqcTokenContractAddr).transfer(liquidityAddress, totalToken/10);  // 10 %
        Token(AqcTokenContractAddr).transfer(msg.sender, totalToken - (totalToken/10));  // 90% 
        // set sell track after the transaction
        setSellTrack(_usdtAmount);
        return true;
    }

    
    function showAllTrade() public view returns (address[] memory, uint256[] memory) {
        require(SellTrackAddr.length > 0, "Trade data not found");
        return (SellTrackAddr, SellTrackAddrAmount);
    }


    function setPresaleRate(uint256 _presaleRate) public onlyOwner {
        presaleRate = _presaleRate;
    }
    

    // It will mark entry in client SellTrack (it should be private)
    function setSellTrack(uint256 _usdtAmount) private {
        uint256 x = 0;
        for (uint256 i = 0; i < SellTrackAddr.length; i++) {
            if (SellTrackAddr[i] == msg.sender) {
                // address already present
                x = 1;
                // update SellTrackAddrAmount value when value already present
                SellTrackAddrAmount[i] = SellTrackAddrAmount[i] + _usdtAmount;
            }
        }
        if (x == 0) {
            // address not present then insert
            SellTrackAddr.push(msg.sender);
            // When address not present or first entry then push amount at last place
            SellTrackAddrAmount.push(_usdtAmount);
        }

        // PayOutCoin Fund Count Update
        TotalCollectedBNBFund = TotalCollectedBNBFund + _usdtAmount;
    }


    
    function retrieveStuckedERC20Token(address _tokenAddr, uint256 _amount, address _toWallet) public onlyOwner returns(bool){
        Token(_tokenAddr).transfer(_toWallet, _amount);
        return true;
    }

    function AQCBalance() public view returns(uint256){
        return (Token(AqcTokenContractAddr).balanceOf(address(this)));
    }
}