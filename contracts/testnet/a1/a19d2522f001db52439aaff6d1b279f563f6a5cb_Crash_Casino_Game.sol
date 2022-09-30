/**
 *Submitted for verification at BscScan.com on 2022-09-29
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

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract Crash_Casino_Game is SignVerify , Ownable, ReentrancyGuard{
    
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
        contractbalance_P = 2;
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
        balance = address(this).balance;
        _betamount = msg.value;

        betcount[_msgSender()][_cycleID] = true;
        betHolders[_msgSender()][_cycleID] = true;

        _afterCapped = (balance.mul(contractbalance_P)).div(100);

        require(_betamount <= _afterCapped, "The contract balance is less than the bet Amount");

        taxPercentage = (_betamount.mul(TaxFee)).div(100);
        _betamount = _betamount.sub(taxPercentage);

        totalBetAmount[_cycleID] += _betamount;

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
                _reward,
                _nonce
            )
        );
        require(!usedHash[hash], "Invalid Hash"); 
        require(recoverSigner(hash, signature) == signer, "Signature Failed");
        usedHash[hash] = true;

        uint256 _tax_P;
        uint256 contract_balance;
        uint256 contract_balance_PER;
        contract_balance = address(this).balance;
        contract_balance_PER = (contract_balance.mul(1)).div(100);

        if(_reward > contract_balance_PER )
        {
            _reward = contract_balance_PER;
        }

        _tax_P = (_reward.mul(devTax)).div(100);
        payable(devAddress).transfer(_tax_P);

        _reward = _reward - _tax_P;
        payable(_msgSender()).transfer(_reward);

        betHolders[_msgSender()][_cycleID] = false;
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