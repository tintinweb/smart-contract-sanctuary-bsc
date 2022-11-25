/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function _approve(address owner, address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

abstract contract Pausable is Context {

    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused()
        public 
        view 
        virtual 
        returns (bool) 
    {   return _paused;     }

    modifier whenNotPaused(){
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause()
        internal 
        virtual 
        whenNotPaused 
    {
      _paused = true;
      emit Paused(_msgSender());
    }

    function _unpause() 
        internal 
        virtual 
        whenPaused 
    {
      _paused = false;
      emit Unpaused(_msgSender());
    }
}

abstract contract SignVerify {

    function splitSignature(bytes memory sig)
        internal
        pure
        returns(uint8 v, bytes32 r, bytes32 s)
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
        returns(address)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        return ecrecover(hash, v, r, s);
    }

    function toString(address account)
        public
        pure 
        returns(string memory) {
        return toString(abi.encodePacked(account));
    }

    function toString(bytes memory data)
        internal
        pure
        returns(string memory) 
    {
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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() 
    {   _status = _NOT_ENTERED;     }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract Withdrawl is SignVerify, Ownable, Pausable, ReentrancyGuard{

    IERC20 public ULE;
    address signerAddress;

    uint256 public Time = 24 hours;
    uint256 public uleAmount = 2000000000000000000000000;
    uint256 public bnbAmount = 300000000000000000000;
    mapping (address => uint256) Passed;
    mapping (bytes32 => bool) public usedHash;

    constructor(address signerAddress_)
    {
        signerAddress = signerAddress_;
        ULE = IERC20(0x3a549866a592C81719F3b714a356A8879E20F5d0);
    }


    function userWithdraw(uint256 uleAmount_, uint256 bnbAmount_, uint256 nonce_, bytes memory signature)
    external
    nonReentrant
    whenNotPaused
    {
        require(msg.sender == tx.origin," External Err ");
        require(Passed[msg.sender] < block.timestamp," Wait for Next Transection ");
        require(uleAmount_ <= uleAmount , " Daily Limit Exceeds ");
        require(bnbAmount_ <= bnbAmount, " Daily Limit Exceeds ");
        internalWithdraw(uleAmount_, bnbAmount_, nonce_, signature);
    }

    function internalWithdraw(uint256 _uleAmount, uint256 _bnbAmount, uint256 _nonce, bytes memory signature)
    internal
    {
        bytes32 hash = keccak256(   
              abi.encodePacked(   
                toString(address(this)),   
                toString(msg.sender),
                _nonce,
                _uleAmount,
                _bnbAmount
              )
          );

        require(!usedHash[hash], "Invalid Hash");
        require(recoverSigner(hash, signature) == signerAddress, "Signature Failed");   
        
        Passed[msg.sender] = block.timestamp + Time;
        usedHash[hash] = true;
        ULE.transfer(msg.sender, _uleAmount);
        payable(msg.sender).transfer(bnbAmount);
    }

    function pauseContract()
    external
    onlyOwner
    {   _pause();   }

    function unPauseContract()
    external
    onlyOwner 
    {   _unpause();     }

    function updateTime(uint256 newTime)
    external
    onlyOwner
    {   Time = newTime;   }

    function updateBNBAmount(uint256 bnbAmount_)
    external
    onlyOwner
    {   bnbAmount = bnbAmount_;   }

    function updateUleAmount(uint256 uleAmount_)
    public
    onlyOwner
    {   uleAmount = uleAmount_;   }

    function updateSignerAddress(address signerAddress_)
    public
    onlyOwner
    {   signerAddress = signerAddress_;   }

    function withdrawToken(address tokenAddress, uint256 amount)
    external
    onlyOwner
    {   IERC20(tokenAddress).transfer(owner(),amount);   }

    function emergencyWithdrawToken()
    public
    onlyOwner
    {   ULE.transfer(owner(),ULE.balanceOf(address(this)));   }

    function withdrawBNB(uint256 amount)
    public
    onlyOwner
    {   payable(owner()).transfer(amount);  }

    function emergencyWithdrawBNB()
    public
    onlyOwner
    {   payable(owner()).transfer(address(this).balance);  }

    function transferFund() external payable{}

}