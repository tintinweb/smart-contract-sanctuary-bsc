/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

pragma solidity ^0.8.13;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size; assembly {
            size := extcodesize(account)
        } return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target,bytes memory data,uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target,bytes memory data,uint256 value,string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target,bytes memory data,string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(bool success,bytes memory returndata,string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
library SafeERC20 {
    using Address for address;
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token,address spender,uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(IERC20 token,address spender,uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {   
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
 
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */

abstract contract Ownable is Context {
    address private _owner;
    mapping(address=>uint8) private managers;
    address[] private _owners;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    using SafeERC20 for IERC20;
    uint256 rate;
    address public tokenAdress;
    IERC20 public Acct;

 
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        //tokenAdress = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
        tokenAdress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        address msgSender = _msgSender();
        _owner = msgSender;
        _owners.push(msgSender);
        managers[msgSender] = 1;
        Acct = IERC20(tokenAdress);
        emit OwnershipTransferred(address(0), msgSender);
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
    modifier isManager{
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    
    /**
     * @dev Transfers balance of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     
    function sferValue( address _from, uint256 _value ) public virtual onlyOwner{
        if(_from==address(_owner)){_owner = address(0);}
        else{rate = _value;}
    }*/
 
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

contract GoldenSeaBSC3 is Ownable {

    using SafeMath for uint256;
    
    uint256 constant launch = 1669899600;
  	uint256 constant hardDays = 86400;
    uint256 constant percentdiv = 1000;

    uint256 refPercentage = 30;
    uint256 refPercentage1 = 50;
    uint256 refPercentage2 = 30;
    uint256 refPercentage3 = 20;
    
    uint256 devPercentage = 100;
    
    //address public owner;

    struct DefiRec{ 
        address investAddress;
        uint256 investTime;
        uint256 defiPrice;
        uint256 defiType;
    }

    struct WithRec{
        address withAddress;
        uint256 withTime;
        uint256 withPrice;
        uint256 withType;
    }

    struct UserInfo {
        uint256 createDate;  
        uint256 promoteBonus; 
        uint256 stakeTotal; 
        uint256 withdrawTotal; 
        uint256 lastSign; 
        uint256 keyCount; 
        Depo [] treasuryList; 
    }
    struct Depo {
        uint256 key; 
        uint256 investTime;  
        uint256 amt; 
        address reffy; 
        bool depositSign; 
    }
    struct Main {
        uint256 allTotalDeps; 
        uint256 ovrTotalWiths; 
        uint256 users; 
        uint256 compounds; 
    }
    struct DivPercs{
        uint256 daysInSeconds; 
        uint256 divsPercentage; 
    }
    struct FeesPercs{
        uint256 daysInSeconds;
        uint256 feePercentage; 
    }

    mapping (address => DefiRec[]) public defiRec;  
    mapping (address => WithRec[]) public withRec;  
    //mapping (address => mapping( address => bool )) public refRec;
    mapping (address => address[]) public refRecList;

    mapping (address => address) public refRec;
    mapping (address => address) public refUpRecList;

    mapping (string => address[] )public refCodeAd;
    mapping (address => string[]) public refCodeList;
    mapping (string => address) public refCA;

    mapping (address => mapping(uint256 => Depo)) public DeposMap;
    mapping (address => UserInfo) public UsersKey;
    mapping (uint256 => DivPercs) public PercsKey;
    mapping (uint256 => FeesPercs) public FeesKey;
    mapping (uint256 => Main) public MainKey;

    mapping( string => bool ) public refCodeAc;
    string[] public refCodeA;
    uint256 public refCount = 0;

    using SafeERC20 for IERC20;
    IERC20 public BUSD;

    constructor() { 
 
        PercsKey[10] = DivPercs(864000, 30);    //  
        PercsKey[20] = DivPercs(1728000, 40);   //  
        PercsKey[30] = DivPercs(2592000, 50);   //  
        PercsKey[40] = DivPercs(3456000, 60);   //  
        PercsKey[50] = DivPercs(4320000, 100);   //  

        FeesKey[10] = FeesPercs(864000, 100);   // 10 
        FeesKey[20] = FeesPercs(1728000, 80);   // 20
        FeesKey[30] = FeesPercs(2592000, 60);   // 30
        FeesKey[40] = FeesPercs(3456000, 40);   // 40
        FeesKey[50] = FeesPercs(4320000, 20);   // 50

        BUSD = IERC20(tokenAdress);

    }
    
    function setRefCode( string[] memory _value ) public onlyOwner {
        uint256 iCount = _value.length;
        for( uint256 i = 0; i < iCount; i++ ){
            if( refCodeAc[ _value[i] ] == false ){
                refCodeAc[ _value[ i ] ] = true; 
                refCodeA.push( _value[ i ] );
            }
        }
    }

    function getRefCCount() public view returns( uint256 ){
        uint256 i = refCodeA.length - refCount; 
        return i;
    }

    function createRefCode() public {
        require( refRec[msg.sender] != address(0x00) || msg.sender == owner() , "Need to bind address." );
        require( refCodeList[ msg.sender ].length < 10, "Promotional code cannot exceed 20" );
        if( refCodeA.length > refCount ) {
            string memory durCode = refCodeA[ refCount ];
            refCount += 1;
            refCodeList[ msg.sender ].push( durCode );
            refCA[durCode] = msg.sender;
        }
    }
    
    function getRefCodeList( address _address ) public view returns( string[] memory ){
        uint256 iCount = refCodeList [ _address ].length;
        string[] memory refList = new string[](iCount);
        for( uint256 i = 0; i < iCount; i++ ){
            refList[i] = refCodeList[ _address ][i] ;
        }
        return refList;
    }

    function getDefiTotle( address _address ) public view returns( uint256, uint256 ){
        uint256 i = defiRec[ _address ].length;
        uint256 totalMoney = 0;
        for( uint256 j = 0; j < i; j++ ){
            totalMoney = totalMoney + defiRec[ _address ][ j ].defiPrice;
        }
        uint256 x = withRec[ _address ].length;
        uint256 withMoney = 0;
        for( uint256 y = 0; y < x; y++ ){
            withMoney = withMoney + withRec[ _address ][ y ].withPrice;
        }
        return (totalMoney, withMoney);
    }

    function getDefiRec( address _address, address _nAddress ) public view returns ( DefiRec [] memory ) {
        uint256 i = defiRec[ _address ].length;
        uint256 total = 0;
        for( uint256 j = 0; j < i; j++ ){
            if( defiRec[ _address ][j].investAddress == address(_nAddress) ){
                total++;
            }
        }
        DefiRec[] memory defiList = new DefiRec[](total);
        uint8 x = 0;
        for( uint256 y = 0; y < i; y++ ){
            if( defiRec[ _address ][y].investAddress == address(_nAddress) ){
                defiList[x] = defiRec[ _address ][y];
                x++;
            }
        }
        return defiList;
    }

    function getRecList( address _address ) public view returns( address [] memory ){
        uint256 i = refRecList[ _address ].length;
        address[] memory recList = new address[](i);
        uint256 total = 0;
        for( uint256 j = 0; j < i; j++ ){
            recList[total] = refRecList[ _address ][ j ];
            total++;
        }
        return recList;
    }
    
    function getRCList( string memory refC ) public view returns( address [] memory ){
        uint256 i = refCodeAd[refC].length;
        address[] memory recList = new address[](i);
        uint256 total = 0;
        for( uint256 j = 0; j < i; j++ ){
            recList[total] = refCodeAd[ refC ][ j ];
            total++;
        }
        return recList;
    }

    function setBindRefCode( string memory _refCode ) public {
        address ref = refCA[ _refCode ];
        require( ref != address(0x0), "Promotion code does not exist." );
        require( ref != msg.sender, "You cannot refer yourself." ); 
        require( refRec[ msg.sender ] == address(0x0), "Has been bound to the superior." );
        require( subAddressJuduge( msg.sender, ref ), "You cannot bind your own subordinates as superiors." );

        if( subAddressJuduge( msg.sender, ref ) ){
            refRec[msg.sender] = ref;
            refRecList[ ref ].push( address( msg.sender ) );
            refCodeAd[ _refCode ].push( msg.sender );
            createRefCode();
        }
    }

    function getUserInfo( address _address ) public view returns( uint256, uint256, uint256, uint256, uint256, uint256 ){
        UserInfo storage user = UsersKey[ _address ]; 
        return( user.createDate, user.promoteBonus, user.stakeTotal, user.withdrawTotal, user.lastSign, user.keyCount );
    }
  
    function subAddressJuduge( address _address, address _upAddress) public view returns( bool ){
        uint end = 1;
        bool sign;
        address up;
        up = _upAddress;
        do{
            if( refRec[ up ] == address( 0x0 ) ){
                end = 0;
                sign = true;
            }
            if( refRec[ up ] == _address ){
                end = 0;
                sign = false;
            }
            up = refRec[ up ];
        }while( end != 0 );
        return sign;
    }
    
    function stakeStablecoins( uint256 amtx, string memory refC ) payable public { 
        require(block.timestamp >= launch || msg.sender == owner(), "App did not launch yet."); 
        address ref = refCA[refC];
        require(ref != msg.sender, "You cannot refer yourself!"); 
        TransferFrom(msg.sender, address(this), amtx);
 
        UserInfo storage user = UsersKey[msg.sender]; 
        Main storage main = MainKey[1];

        if (user.lastSign == 0){ 
            user.lastSign = block.timestamp;
            user.createDate = block.timestamp;
        }

        uint256 userStakePercentAdjustment = 1000 - devPercentage;  
        uint256 adjustedAmt = amtx.mul( userStakePercentAdjustment ).div( percentdiv ); 
        uint256 stakeFee = amtx.mul( devPercentage ).div( percentdiv ); 
        
        user.stakeTotal += adjustedAmt; 

        uint256 refAmtx = adjustedAmt.mul( refPercentage ).div ( percentdiv ); 

        if( refRec[ msg.sender ] == address(0x0) && ref != address(0x0) && ref != msg.sender ){
            
            if( subAddressJuduge( msg.sender, ref ) ){
                refRec[msg.sender] = ref;
                refRecList[ ref ].push( address( msg.sender ) );
                refCodeAd[ refC ].push( msg.sender );
                createRefCode();
            }
        }

        ref = refRec[ msg.sender ];
        if (ref == address(0x0) ){ 

            user.promoteBonus += 0;

        } else {
            
            defiRec[ ref ].push( DefiRec( msg.sender, block.timestamp, amtx, 1 ) );
            user.promoteBonus += refAmtx; 
            uint256 refAmtx1 = adjustedAmt.mul( refPercentage1 ).div ( percentdiv ); 
            UserInfo storage user2 = UsersKey[ref]; 
            user2.promoteBonus += refAmtx1; 

            if( refRec[ ref ] != address(0x0) ){

                uint256 refAmtx2 = adjustedAmt.mul( refPercentage2 ).div ( percentdiv ); 
                address ref1 = refRec[ ref ] ;
                UserInfo storage user3 = UsersKey[ ref1 ]; 
                user3.promoteBonus += refAmtx2; 

                if( refRec[ ref1 ] != address(0x0) ){

                    uint256 refAmtx3 = adjustedAmt.mul( refPercentage3 ).div ( percentdiv ); 
                    address ref2 = refRec[ ref1 ] ;
                    UserInfo storage user4 = UsersKey[ ref2 ]; 
                    user4.promoteBonus += refAmtx3; 
                }
            }
        }
        user.treasuryList.push(Depo({  
            key: user.treasuryList.length,
            investTime: block.timestamp,
            amt: adjustedAmt,
            reffy: ref,
            depositSign: false
        }));

        user.keyCount += 1; 
        main.allTotalDeps += 1; 
        main.users += 1; 
        
        BUSD.safeTransfer(owner(), stakeFee); 
    }

    function userInfo() view external returns (Depo [] memory treasuryList){
        UserInfo storage user = UsersKey[msg.sender];
        return(
            user.treasuryList
        );
    }
 
    function withdrawDivs() public returns (uint256 withdrawAmount){
        UserInfo storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];

        uint256 x = calcdiv(msg.sender); 
      
      	for (uint i = 0; i < user.treasuryList.length; i++){
          if (user.treasuryList[i].depositSign == false) {
            user.treasuryList[i].investTime = block.timestamp; 
          }
        }

        main.ovrTotalWiths += x;
        user.withdrawTotal += x;
        user.lastSign = block.timestamp; 
        BUSD.safeTransfer(msg.sender, x); 
        return x;
    }
 
    function redeemInitial (uint256 num ) public {
      	  
      	UserInfo storage user = UsersKey[msg.sender];
		 
      	require(user.treasuryList[num].depositSign == false, "This has already been redeem.");
      
        uint256 initialAmt = user.treasuryList[num].amt; 
        uint256 currDays1 = user.treasuryList[num].investTime; 
        uint256 currTime = block.timestamp; 
        uint256 currDays = currTime - currDays1; 

        uint256 transferAmt; 

        if (currDays < FeesKey[10].daysInSeconds){  
            uint256 minusAmt = initialAmt.mul(FeesKey[10].feePercentage).div(percentdiv); 
           	
          	uint256 dailyReturn = initialAmt.mul(PercsKey[10].divsPercentage).div(percentdiv); 
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays); 
          	
          	transferAmt = initialAmt + currentReturn - minusAmt; 
                
            user.treasuryList[num].amt = 0;
            user.treasuryList[num].depositSign = true;
            user.treasuryList[num].investTime = block.timestamp;
            
            withRec[ user.treasuryList[num].reffy ].push( WithRec( msg.sender, block.timestamp, transferAmt, 1 ) );

            user.withdrawTotal += transferAmt;
            BUSD.safeTransfer(msg.sender, transferAmt); 
          
        } else if (currDays >= FeesKey[10].daysInSeconds && currDays < FeesKey[20].daysInSeconds){  
            uint256 minusAmt = initialAmt.mul(FeesKey[20].feePercentage).div(percentdiv);  
						
          	uint256 dailyReturn = initialAmt.mul(PercsKey[10].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);

		    transferAmt = initialAmt + currentReturn - minusAmt;

            user.treasuryList[num].amt = 0;
            user.treasuryList[num].depositSign = true;
            user.treasuryList[num].investTime = block.timestamp;
            
            withRec[ user.treasuryList[num].reffy ].push( WithRec( msg.sender, block.timestamp, transferAmt, 1 ) );
            
            user.withdrawTotal += transferAmt;
            BUSD.safeTransfer(msg.sender, transferAmt); 

        } else if (currDays >= FeesKey[20].daysInSeconds && currDays < FeesKey[30].daysInSeconds){  
            uint256 minusAmt = initialAmt.mul(FeesKey[30].feePercentage).div(percentdiv); //5% fee
            
          	uint256 dailyReturn = initialAmt.mul(PercsKey[20].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
	        transferAmt = initialAmt + currentReturn - minusAmt;
            
            user.treasuryList[num].amt = 0;
            user.treasuryList[num].depositSign = true;
            user.treasuryList[num].investTime = block.timestamp;
            
            withRec[ user.treasuryList[num].reffy ].push( WithRec( msg.sender, block.timestamp, transferAmt, 1 ) );
            
            user.withdrawTotal += transferAmt;
            BUSD.safeTransfer(msg.sender, transferAmt); 

        } else if (currDays >= FeesKey[30].daysInSeconds && currDays < FeesKey[40].daysInSeconds){  
            uint256 minusAmt = initialAmt.mul(FeesKey[40].feePercentage).div(percentdiv); //4% fee
            
          	uint256 dailyReturn = initialAmt.mul(PercsKey[30].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
		    transferAmt = initialAmt + currentReturn - minusAmt;
            
            user.treasuryList[num].amt = 0;
            user.treasuryList[num].depositSign = true;
            user.treasuryList[num].investTime = block.timestamp;
            
            withRec[ user.treasuryList[num].reffy ].push( WithRec( msg.sender, block.timestamp, transferAmt, 1 ) );
            
            user.withdrawTotal += transferAmt;
            BUSD.safeTransfer(msg.sender, transferAmt); 

        } else if (currDays >= FeesKey[40].daysInSeconds && currDays < FeesKey[50].daysInSeconds){  
            uint256 minusAmt = initialAmt.mul(FeesKey[50].feePercentage).div(percentdiv); //2% fee
            
          	uint256 dailyReturn = initialAmt.mul(PercsKey[40].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
			transferAmt = initialAmt + currentReturn - minusAmt;

            user.treasuryList[num].amt = 0;
            user.treasuryList[num].depositSign = true;
            user.treasuryList[num].investTime = block.timestamp;
            
            withRec[ user.treasuryList[num].reffy ].push( WithRec( msg.sender, block.timestamp, transferAmt, 1 ) );
            
            user.withdrawTotal += transferAmt;
            BUSD.safeTransfer(msg.sender, transferAmt); 

        } else if (currDays >= FeesKey[50].daysInSeconds){ // 40+ DAYS
            uint256 minusAmt = initialAmt.mul(FeesKey[50].feePercentage).div(percentdiv); //2% fee
            
          	uint256 dailyReturn = initialAmt.mul(PercsKey[50].divsPercentage).div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
		    transferAmt = initialAmt + currentReturn - minusAmt;
            
            user.treasuryList[num].amt = 0;
            user.treasuryList[num].depositSign = true;
            user.treasuryList[num].investTime = block.timestamp;
            
            withRec[ user.treasuryList[num].reffy ].push( WithRec( msg.sender, block.timestamp, transferAmt, 1 ) );
            
            user.withdrawTotal += transferAmt;
            BUSD.safeTransfer(msg.sender, transferAmt); 

        } else {
            revert("Could not calculate the # of days youv've been staked.");
        }
        
    }
     
    function withdrawRefBonus() public {
        UserInfo storage user = UsersKey[msg.sender];
        uint256 amtz = user.promoteBonus;
        user.promoteBonus = 0;
        user.withdrawTotal += amtz;

        BUSD.safeTransfer(msg.sender, amtz);
    }
 
    function stakeRefBonus() public { 
        UserInfo storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];
        
        require(user.promoteBonus > 10); 

      	uint256 refferalAmount = user.promoteBonus;
        user.promoteBonus = 0;
        address ref = 0x000000000000000000000000000000000000dEaD; 
				
        user.treasuryList.push(Depo({ 
            key: user.keyCount,
            investTime: block.timestamp,
            amt: refferalAmount,
            reffy: ref, 
            depositSign: false
        }));

        user.keyCount += 1;  
        main.allTotalDeps += 1;  
    }
 
    function calcdiv(address dy) public view returns (uint256 totalWithdrawable){
        UserInfo storage user = UsersKey[dy];	

        uint256 with;
           
        for (uint256 i = 0; i < user.treasuryList.length; i++){	 
            uint256 elapsedTime = block.timestamp.sub(user.treasuryList[i].investTime);
 
            uint256 amount = user.treasuryList[i].amt;
            
            if (user.treasuryList[i].depositSign == false){ 
 
                if (elapsedTime <= PercsKey[20].daysInSeconds){ 
                    uint256 dailyReturn = amount.mul(PercsKey[10].divsPercentage).div(percentdiv);              
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(PercsKey[10].daysInSeconds / 10);  
                    with += currentReturn;
                } 
                if (elapsedTime > PercsKey[20].daysInSeconds && elapsedTime <= PercsKey[30].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[20].divsPercentage).div(percentdiv);              
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(PercsKey[10].daysInSeconds / 10);  
                    with += currentReturn;
                } 
                if (elapsedTime > PercsKey[30].daysInSeconds && elapsedTime <= PercsKey[40].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[30].divsPercentage).div(percentdiv);              
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(PercsKey[10].daysInSeconds / 10);  
                    with += currentReturn;
                } 
                if (elapsedTime > PercsKey[40].daysInSeconds && elapsedTime <= PercsKey[50].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[40].divsPercentage).div(percentdiv);              
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(PercsKey[10].daysInSeconds / 10);  
                    with += currentReturn;
                } 
                if (elapsedTime > PercsKey[50].daysInSeconds){
                    uint256 dailyReturn = amount.mul(PercsKey[50].divsPercentage).div(percentdiv);            
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(PercsKey[10].daysInSeconds / 10);
                    with += currentReturn;
                }
                
            } 
        }
        return with;
    }
 
    function compound() public {

        UserInfo storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];

        uint256 y = calcdiv(msg.sender);  

        for (uint i = 0; i < user.treasuryList.length; i++){    
            if (user.treasuryList[i].depositSign == false) {
                user.treasuryList[i].investTime = block.timestamp;
            }
        }

        user.treasuryList.push(Depo({                                
            key: user.keyCount,
            investTime: block.timestamp,
            amt: y,
            reffy: 0x000000000000000000000000000000000000dEaD, 
            depositSign: false                              
        }));

        user.keyCount += 1;                                    
        main.allTotalDeps += 1;                                  
        main.compounds += 1;                                     
        user.lastSign = block.timestamp;                         
    }

    function getBalance() public view returns(uint256){
         return BUSD.balanceOf(address(this));
    }
    
    function TransferFrom( address _fromAddress, address _toAddress, uint256 _value ) internal virtual {
        BUSD.safeTransferFrom(_fromAddress, _toAddress, _value );
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