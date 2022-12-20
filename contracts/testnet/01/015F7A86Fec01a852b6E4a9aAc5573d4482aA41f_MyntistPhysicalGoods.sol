// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
contract Verification {
    function verify( address _signer, address _to, uint256 _amount, string memory _message, uint256 _nonce, bytes memory signature) internal pure returns (bool) {
        bytes32 messageHash = getMessageHash(_to, _amount, _message, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }
    function getMessageHash( address _to, uint256 _amount, string memory _message, uint256 _nonce) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount, _message, _nonce));
    }
    function getEthSignedMessageHash(bytes32 _messageHash) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }
    function splitSignature(bytes memory sig) internal pure returns ( bytes32 r, bytes32 s, uint8 v ) {
        require(sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
interface IERC20Token { //WBNB, ANN
    function transferFrom(address _from,address _to, uint _value) external returns (bool success);
    function balanceOf(address _owner) external returns (uint balance);
    function transfer(address _to, uint256 _amount) external returns (bool);
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
contract MyntistPhysicalGoods is Ownable, Verification {
    uint256 private SERVICE_FEE = 10;
    address public myntAddress;
    constructor(address _mynt) {
        myntAddress = _mynt;
    }
    using SafeMath for uint256;
    mapping(address => mapping(uint256 => bool)) seenNonces;
    mapping(address => uint256) sellerBalancesBNB;
    mapping(address => uint256) sellerBalancesMynt;

    struct SellerAndPrices {
        address seller;
        uint256 amount;
    }
    
    struct OrderData {
        string orderData;
        uint256 totalAmount;
        uint8 currencyType;
        SellerAndPrices[] sellerAndPrices;
    }

    event NftTransferred(uint256 tokenId, uint256 price, address from, address to);

    function createOrder(OrderData memory _orderData) public payable {
        require(_orderData.currencyType == 1 || _orderData.currencyType ==2 );
        if(_orderData.currencyType == 1) {
            require(msg.value > _orderData.totalAmount, "Invalid Amount!");
        }
        else {
            transferERC20ToOwner(msg.sender, address(this), _orderData.totalAmount, myntAddress);
        }
        SellerAndPrices[] memory sellerAndPrices = _orderData.sellerAndPrices;
        for(uint256 x = 0; x < sellerAndPrices.length; x++) {
            uint256 sellerShare = calculatePercentValue(sellerAndPrices[x].amount, SERVICE_FEE);
            if(_orderData.currencyType == 1) {
                uint256 sellerBalance = sellerBalancesBNB[sellerAndPrices[x].seller];
                sellerBalancesBNB[sellerAndPrices[x].seller] = sellerBalance + sellerShare;
            }
            else {
                uint256 sellerBalance = sellerBalancesMynt[sellerAndPrices[x].seller];
                sellerBalancesMynt[sellerAndPrices[x].seller] = sellerBalance + sellerShare;
            }
        }
    }
    fallback () payable external {}
    receive () payable external {}
    function transferERC20ToOwner(address from, address to, uint256 amount, address tokenAddress) private {
        IERC20Token token = IERC20Token(tokenAddress);
        uint256 balance = token.balanceOf(from);
        require(balance >= amount, "insufficient balance" );
        token.transferFrom(from, to, amount);
    }
    function calculatePercentValue(uint256 total, uint256 percent) pure private returns(uint256) {
        uint256 division = total.mul(percent);
        // uint256 percentValue = division.div(10000);//*100
        uint256 percentValue = division.div(100);//*100
        return percentValue;
    }
    function transferSellerMynts(address _seller) public onlyOwner {
        IERC20Token myntToken = IERC20Token(myntAddress);
        uint256 balance = myntToken.balanceOf(address(this));
        uint256 sellerBalance = sellerBalancesMynt[_seller];
        require(balance >= sellerBalance, "insufficient balance" );
        myntToken.transfer(_seller, sellerBalance);
    }
    function transferSellerBNB(address _seller) public onlyOwner {
        uint256 balance = address(this).balance;
        uint256 sellerBalance = sellerBalancesBNB[_seller];
        require(balance >= sellerBalance, "insufficient balance" );
        payable(_seller).transfer(sellerBalance);
    }
    function withdrawMynt() public onlyOwner {
        IERC20Token myntToken = IERC20Token(myntAddress);
        uint256 balance = myntToken.balanceOf(address(this));
        require(balance >= 0, "insufficient balance" );
        myntToken.transfer(owner(), balance);
    }
    function withdrawBNB() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
    function updateServiceFee(uint256 _fee) public onlyOwner {
        SERVICE_FEE = _fee;
    }
    function updateMyntAddress(address usdc) public onlyOwner {
        myntAddress = usdc;
    }
}