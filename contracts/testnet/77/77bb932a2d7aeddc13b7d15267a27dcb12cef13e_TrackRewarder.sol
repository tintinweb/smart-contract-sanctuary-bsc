/**
 *Submitted for verification at BscScan.com on 2022-02-14
*/

pragma solidity >=0.6.0 <0.8.0;

//pragma experimental ABIEncoderV2;
//import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";


//import "../node_modules/@opengsn/gsn/contracts/BaseRelayRecipient.sol";
//import "../node_modules/@opengsn/gsn/contracts/interfaces/IKnowForwarderAddress.sol";
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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

    constructor() internal {
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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
}}

contract TrackRewarder is SafeMath,ReentrancyGuard{




IERC20 private _token;
    address public owner;
    uint _bal;

event trackAdded(address indexed uploader,bytes32 songMeta,uint now);
event payed(address indexed beneficiary, uint256 amountPayed);
event uploaderAdded(address indexed newUploader);
constructor (IERC20 token) public {
    owner = msg.sender;
    _token = token;
}




struct track{
bytes32 metadata;
address  owner;
uint timeUploaded;
}

modifier onlyOwner{
    require(msg.sender == owner, "you are not the owner");
        _;
}

modifier notUploader(address target){
    require(Uploaders[target].active==false,"you are already an uploader");
    _;
}

modifier anUploader(address _targ){
    require(Uploaders[_targ].active==true,'you have not been activated to upload songs');
    _;
}

modifier notEmpty(address _targ){
    require(unclaimedTokens[_targ].earned>=1,"you do not have any tokens to redeem");
    _;
}




struct Uploader{
    uint _tracks;
    address _add;
    bool active;
    uint earned;
    bytes32[] buffers;
}


address[] public uploaders;
bytes32[] public metadatas;
bytes32[] songBuffers;

//mapping(uint=>Uploader) tokenBalance;
mapping(address=>Uploader) Uploaders;
mapping(address=>track) trackOwners;
mapping(bytes32=>track) TrackMetas;
mapping(address=>Uploader) unclaimedTokens;

function toDecimal(uint _tokens) internal pure returns(uint){
     uint decimalss = 18;
      uint  _totalSupplys = (_tokens)*10**uint(decimalss);
      return _totalSupplys;
}

function addUploader(address newUploader) public onlyOwner notUploader(newUploader) returns(address){
    Uploaders[newUploader]._add=newUploader;
    Uploaders[newUploader].active=true;
    
    uploaders.push(newUploader);
    emit uploaderAdded(newUploader);
    return newUploader;
    
}

function removeUploader(address uploader) public onlyOwner returns(address){
     Uploaders[uploader].active=false;
     
     
     
}


//allows an authorized uploader to upload songs
//songBuffer is the ipfs cid that will be returned in the frontend
//meta is a precalculated hash that will be stored on the contract
function addTrack(address uploader,bytes32 songBuffer) public anUploader(msg.sender) nonReentrant returns(bytes32 meta){
    meta = (keccak256 (abi.encodePacked (now ,uploader)));
    trackOwners[(msg.sender)].owner = uploader;
    TrackMetas[meta].metadata = meta;
    TrackMetas[meta].owner=uploader;
    TrackMetas[meta].timeUploaded=now;
    emit trackAdded (uploader,meta,now);
    metadatas.push(meta);
    Uploaders[msg.sender]._tracks++;
    unclaimedTokens[msg.sender].earned=safeAdd(unclaimedTokens[msg.sender].earned,toDecimal(1));
    Uploaders[msg.sender].buffers.push(songBuffer);
    return(meta);
   
}

//allows anyone to see the owner of a track and when it was uploaded 
function seeTrackDetails(bytes32 Trackmeta) public view returns(address,uint){
    return (TrackMetas[Trackmeta].owner,TrackMetas[Trackmeta].timeUploaded);
}

//allows an uploader to see all his song buffers/cids
function checkMyBuffers() public anUploader(msg.sender) view returns(bytes32[] memory){
   return Uploaders[msg.sender].buffers;
}

//internal function to redeem tokens
    function redeem(address _artist) internal notEmpty(_artist) returns(bool){
        uint toSend=checkPendingTokens();
        _token.transfer(_artist,toSend);
         unclaimedTokens[msg.sender].earned=0;
         emit payed(_artist,toSend);
        
        
    }
    
    
    //allows an uploader to see the tokens he has not claimed yet
    function checkPendingTokens() public view returns(uint){
        
        return unclaimedTokens[msg.sender].earned;
    }
    
    //a simple function to check the contract allowance
    function remAllowance(address tokenOwner) public view returns(uint256){
      return  _token.allowance(tokenOwner,address(this));
    }
    
    //main function that transfers all unclaimed tokens to the uploader
    function getTokens(address _to) public  returns(uint) {
        redeem(_to);
       
    }
    
   

  /*	function versionRecipient() external virtual view override returns (string memory) {
		return "1.0";
	}

   function getTrustedForwarder() public view override returns(address) {
		return trustedForwarder;
	}
    */
}