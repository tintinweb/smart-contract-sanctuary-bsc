/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

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



interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Sale is Ownable {

    /*
    * @ Atenção a partir da versão 0.8.0 Solidity não é mais preciso utilizar SafeMath ou Math
    * Mas por medidas de precaução recomendo manter o uso do SafeMath
    */
    using SafeMath for uint256;
    // BUSD
    IBEP20 public busd;
    address public walletMarketing;
    uint256 public valueBUSD = 170000000000000000000;

    mapping(address => SaleNFT) public sale;

    struct SaleNFT {
        uint256 idNFT;
        uint256 priceNFT;
        uint256 totalBUSD;
    }

    // Constructor
    constructor (IBEP20 _busd)
    {
        busd = _busd;
    }

    function currentID(uint256 amount) private {
        SaleNFT storage sell = sale[address(this)];
        sell.idNFT += 1;
        sell.totalBUSD += amount;
    }

    function perUser(uint256 amount, address user) private {
        SaleNFT storage sell = sale[user];
        sell.idNFT += 1;
        sell.totalBUSD += amount;
    }

    function buyNft(uint256 amount) public {
        require(amount >= valueBUSD, "Value Error");
        // Gera ID
        currentID(amount);
        // User Valor
        perUser(amount, _msgSender());

        IBEP20(busd).transferFrom(_msgSender(), address(this), amount);
        // Transfer os BUSD
        withdrawBUSD();
    }

    function withdrawBUSD() private {
       uint256 balance = IBEP20(busd).balanceOf(address(this));
       IBEP20(busd).transfer(walletMarketing, balance);
       balance = 0;
    }

    function withdrawManual(uint256 amount) external onlyOwner {
       IBEP20(busd).transfer(walletMarketing, amount);
    }

    function withdrawBNB() external onlyOwner {
       uint256 valueBNB = address(this).balance;
       payable(walletMarketing).transfer(valueBNB);
       valueBNB = 0;
    }

    // Define o endereço de Taxas
    function setWalletMarketing(address _walletMarketing) external onlyOwner {
        walletMarketing = _walletMarketing;
    }

    function setValue(uint256 value) external onlyOwner {
        valueBUSD = value;
    }

    function addManual(uint256 amount, address user) external onlyOwner {
        // Gera ID
        currentID(amount);
        // User Valor
        perUser(amount, user);
    }

    function totalRaised() public view returns(uint256 totalBUSD) {
        SaleNFT storage sell = sale[address(this)];
        return (sell.totalBUSD);
    }

}