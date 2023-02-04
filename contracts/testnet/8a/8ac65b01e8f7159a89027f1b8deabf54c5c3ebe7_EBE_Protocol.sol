/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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
    function transferOwnership(address newOwner) public virtual onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint private constant _NOT_ENTERED = 1;
    uint private constant _ENTERED = 2;
    uint private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }
    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }
    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address to, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
}

contract EBE_Protocol is  Ownable, ReentrancyGuard {
    constructor (IERC20 _EBE, address _refer) {
        EBE=_EBE;
        refer=_refer;
    }
    IERC20  public immutable EBE;
    address private immutable refer;

    uint private  referFee = 25;                                    
    uint private  buytokenPrice = 0.014 ether;                                         
    uint private  buytokenTokensAmount = 2000000000000000000000;     
    uint private  salePrice = 100000;                               


    function BuyToken() external payable nonReentrant() {
        require(msg.value==buytokenPrice, "wrong BNB amount");
        (bool success, bytes memory response) = address(EBE).call(
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                _msgSender(),
                buytokenTokensAmount)
            );
        require(success && abi.decode(response, (bool)), "Failed to send tokens!");
        payable(address(refer)).transfer(buytokenPrice*referFee/100); 
    }

    function buy() external payable nonReentrant() {
        require(msg.value >= 0.01 ether, "min 0.01BNB");                          
        (bool success, bytes memory response) = address(EBE).call(
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                _msgSender(),
                msg.value*salePrice)            
            );
        require(success && abi.decode(response, (bool)), "Failed to send tokens!");
        payable(address(refer)).transfer(msg.value*referFee/100);
    }

    function withdraw() external onlyOwner {
        payable(_msgSender()).transfer(address(this).balance);
    }

    function withdrawEBE(uint _amount) external onlyOwner {
        EBE.transfer(_msgSender(), _amount);
    }

    function setReferFee(uint _referFee) external onlyOwner {
        referFee=_referFee;
    }
    function setbuytokenPrice(uint _buytokenPrice) external onlyOwner {
        buytokenPrice=_buytokenPrice;
    }
    function setbuytokenTokenAmount(uint _buytokenTokensAmount) external onlyOwner {
        buytokenTokensAmount=_buytokenTokensAmount;
    }
    function setSalePrice(uint _salePrice) external onlyOwner {
        salePrice=_salePrice;
    }

    fallback() external payable {}

    receive() external payable {}
}