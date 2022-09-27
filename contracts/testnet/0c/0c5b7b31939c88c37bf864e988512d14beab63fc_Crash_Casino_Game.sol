/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library SafeMath {
 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract SignVerify {

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        return ecrecover(hash, v, r, s);
    }

    function toString(address account) public pure returns (string memory) {
        return toString(abi.encodePacked(account));
    }

    function toString(bytes memory data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
        }
        return string(str);
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


contract Crash_Casino_Game is SignVerify , Ownable{
    
    using SafeMath for uint256;

    uint256 public contractbalance_P;
    uint256 public taxPercentage;
    uint256 private TaxFee;
    uint256 private devTax;
    uint256 public balance; 
    uint256 public _afterCapped;
    uint256 public _betamount;

    address public taxAddress;
    address public devAddress;
    address public signer;

    mapping (bytes32 => bool) public usedHash;
    mapping (address => mapping (uint256 => uint256)) public betAmount;
    mapping (address => mapping (uint256 => bool)) public betHolders;
    mapping (address => mapping (uint256 => bool)) public betcount;
    mapping (uint256 => uint256) public totalBetAmount;
    mapping (uint256 => bool) public poolBalance;

    constructor(address signer_,address taxAddress_,address devAddress_)
    {
        TaxFee = 3;
        devTax= 5;
        contractbalance_P = 30;
        taxAddress = taxAddress_;
        devAddress= devAddress_;
        signer = signer_;
    }

    function SetTax(uint256 _tax) 
    public 
    onlyOwner
    {TaxFee = _tax;}

    function SetDevTax(uint256 _tax) 
    public 
    onlyOwner
    {devTax = _tax;}


    function Place_Bet(uint256 _cycleID)
    public
    payable
    {
        require(!betcount[_msgSender()][_cycleID], "Already Bet");
        
        _betamount = msg.value;

        betcount[_msgSender()][_cycleID] = true;
        betHolders[_msgSender()][_cycleID] = true;

        if(!poolBalance[_cycleID])
        {
            checkBalance();
            poolBalance[_cycleID] = true;
        }

        taxPercentage = (_betamount.mul(TaxFee)).div(100);
        _betamount = _betamount.sub(taxPercentage);

        totalBetAmount[_cycleID] += _betamount;

        require(totalBetAmount[_cycleID] <= _afterCapped, "The contract balance is less than the bet Amount");

        payable(taxAddress).transfer(taxPercentage);
        betAmount[_msgSender()][_cycleID] = _betamount;
    }

    function ClaimAble(uint256 _cycleID, uint256 _reward, uint256 _nonce, bytes memory signature)
    external
    {
        require(betHolders[_msgSender()][_cycleID] == true, "Already Rewarded");

        bytes32 hash = keccak256(   
            abi.encodePacked(   
                toString(address(this)),   
                toString(_msgSender()),
                _nonce
            )
        );
        require(!usedHash[hash], "Invalid Hash");   
        require(recoverSigner(hash, signature) == signer, "Signature Failed");
        usedHash[hash] = true;

        uint256 _tax_P;

            _tax_P = (_reward.mul(devTax)).div(100);
            payable(devAddress).transfer(_tax_P);

            _reward = _reward - _tax_P;
            payable(_msgSender()).transfer(_reward);

        betHolders[_msgSender()][_cycleID] = false;
    }

    function Profit()
    public
    view
    returns(uint256)
    {
        uint256 _balance = address(this).balance;
        uint256 _profit = _balance.sub(balance);
        return _profit;
    }

    function Withdraw(uint256 amount)
    public
    onlyOwner
    {
        payable(owner()).transfer(amount);
    }

    function changeTaxAddress(address taxAddress_)
    public
    onlyOwner
    {
        taxAddress = taxAddress_;
    }

    function Add_Signer(address _signer)
    public
    onlyOwner
    {
        signer  = _signer;
    }

    function changeDevAddress(address devAddress_)
    public
    onlyOwner
    {
        devAddress = devAddress_;
    }

    function checkBalance() 
    internal 
    {
        balance = address(this).balance;
        _afterCapped = (balance.mul(contractbalance_P)).div(100);
    }



    //////////////////////////////////////////////////////////////////////////////////
     mapping (address => uint256) public testingValue;
    function TestingFunction(uint256 _nonce, bytes memory signature)  public 
    {
       bytes32 hash = keccak256(   
            abi.encodePacked(   
                toString(address(this)),   
                toString(_msgSender()),
                _nonce
            )
        );
        require(!usedHash[hash], "Invalid Hash");   
        require(recoverSigner(hash, signature) == signer, "Signature Failed");
        usedHash[hash] = true;
        testingValue[_msgSender()] = 125687;
    }

    function pay() public payable{}
  
}