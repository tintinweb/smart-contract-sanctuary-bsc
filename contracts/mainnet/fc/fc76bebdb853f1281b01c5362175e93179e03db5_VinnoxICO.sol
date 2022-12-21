/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
        _setOwner(_msgSender());
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
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract VinnoxICO is Ownable{


    address public signer;
    uint public percentage;
    IBEP20 public token;
    bool public contractlock;

     

    event Buy(address indexed to ,address[]  reffer,uint buyAmount,uint refferAmount,uint time);

    modifier lock() {
        require(!contractlock, "VinnoxICO : Contract is Locked");
        _;
    }
    constructor(IBEP20 _token,address _signer,uint _percentage) {
        signer = _signer;
        percentage = _percentage;
        token = _token;
    }

    function pause() external onlyOwner {
        contractlock = true;
    }

    function unpause() external onlyOwner {
          contractlock = false;
    }

  

    function updatePercentage(uint _percentage)external onlyOwner{
         percentage = _percentage;
    }


    function updateToken(IBEP20 _token)external onlyOwner{
         token = _token;
    }

    function updateSigner(address _signer)external onlyOwner{
         signer = _signer;
    }

    function depositToken(address _token,uint _amount)external onlyOwner{
        require(_token != address(0),"VinnoxICO : Invalid  Token");
        require(_amount > 0,"VinnoxICO : Invalid  Deposit Amount");
       
        IBEP20(_token).transferFrom(msg.sender,address(this),_amount);

    }

     struct Sig {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function buyToken(address _to,uint _tokenAmount,address[] memory _reffer,uint _expiry,Sig memory _sig)external payable lock{
        require(_to != address(0),"VinnoxICO : Invalid Address");
        require(_reffer.length == 5, "VinnoxICO : Only 5 Reffers");
        require(msg.value > 0 ,"VinnoxICO : Invalid Amount");
        require(_expiry >= block.timestamp,"VinnoxICO : Expired Time");

        
        validateSignature(_to,msg.value,_expiry,_sig);
        sendTokens(_to, _reffer, msg.value,_tokenAmount);
        require(payable(owner()).send(msg.value),"VinnoxICO : BNB Transfer Failed");
            
    }

     function buyFiat(address _to,uint _tokenAmount,uint _amount,address[] memory _reffer,uint _expiry,Sig memory _sig)external lock {
        require(_to != address(0),"VinnoxICO : Invalid Address");
        require(_reffer.length == 5, "VinnoxICO : Only 5 Reffers");
        require(_amount > 0 ,"VinnoxICO : Invalid Amount");
        require(_expiry >= block.timestamp,"VinnoxICO : Expired Time");

        validateSignature(_to,_amount,_expiry,_sig);
        sendTokens(_to, _reffer, _amount,_tokenAmount);            

    }

    function sendTokens(address _to, address[] memory _reffer, uint _amount,uint tokenAmount) internal {

        uint refferAmount;
        uint buyAmount;
        
        (refferAmount,buyAmount) = calculatePercentage(_amount,_reffer.length,tokenAmount);

        if (buyAmount > 0){
            IBEP20(token).transfer(_to,buyAmount);
        }

        if (refferAmount > 0){
            refferAmount = refferAmount / _reffer.length;
            for(uint i=0 ; i<_reffer.length ;i++){
                  IBEP20(token).transfer(_reffer[i],refferAmount);
            }
        }

        emit Buy(_to,_reffer,buyAmount,refferAmount,block.timestamp);
    }

    function calculatePercentage(uint _amount,uint _reffer,uint tokenAmount)public view returns(uint,uint){
         uint refferAmount;
         uint buyAmount;

         buyAmount = (tokenAmount * _amount) / 1e18;
         refferAmount =  ((buyAmount * percentage) / 100e18) * _reffer;
         return (refferAmount,buyAmount);
    }

    function validateSignature(address _to,uint _amount,uint _expiry, Sig memory _sig) public view {
         bytes32 hash = prepareHash(_to,address(this),_amount,_expiry);
         require(ecrecover(hash, _sig.v, _sig.r, _sig.s) == signer , "VinnoxICO : Invalid Signature");
    }

    function prepareHash(address _to,address _contract,uint _amount,uint _expiry)public  pure returns(bytes32){
        bytes32 hash = keccak256(abi.encodePacked(_to,_contract,_amount,_expiry));
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }


    function failcase(address _tokenAdd, uint _amount) external onlyOwner{
        address self = address(this);
        if(_tokenAdd == address(0)) {
            require(self.balance >= _amount,"VinnoxICO : Insufficient BNB Fund");
            require(payable(owner()).send(_amount),"VinnoxICO : BNB Transfer Failed");
        }
        else {
            require(IBEP20(_tokenAdd).balanceOf(self) >= _amount,"VinnoxICO : Insufficient Token Balance");
            require(IBEP20(_tokenAdd).transfer(owner(),_amount),"VinnoxICO : Token Transfer Failed");
        }
    }


}