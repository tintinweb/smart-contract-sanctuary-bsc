/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: Unlicensed
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
abstract contract  Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
 abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);



    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);


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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
 library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

 }
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract swapPlatform is Ownable {
  //  add liquidity
  //  
  //  
  //  
  //  remove stablecoin 
  //  swap

    event _createPair(address indexed _from, address token1Address,address token2Address); //added
    event addLiquidity(address indexed _from, address token1Address,address token2Address, uint token1Value, uint token2Value);//added
    event removeLiquidity(address indexed _from, address token1Address,address token2Address, uint token1Value, uint token2Value);
    event addToken(address indexed _from,address tokenContractAddress, string tokenName); //added
    event _addStableCoin(address indexed _from, address tokenContractAddress,string tokenName);//added
    event _removeStableCoin(address indexed _from, address tokenContractAddress,string tokenName);//added
    event _swap(address indexed _from, address fromTokenContractAddress,address toTokenContractAddress, uint TokenSoldValue, uint valueReceived);

    using SafeMath for uint256;
        function swap(address tokenYouWantToSell, address tokenYouWantToBuy,uint256 amountYouWantSell,uint256 minTokenYouWantToBuy ) public returns(string memory,bool) {



        }

//pair



        function addNewToken(address contractAddress) public returns(string memory) {
            if(tokensInfo[contractAddress].isSubmitedBefore == false){
                uint8 errorNumber;
                
                
                tokensInfo[contractAddress].tokenContractAddress = IERC20(contractAddress);
                tokensInfo[contractAddress].tokenName = tokensInfo[contractAddress].tokenContractAddress.name();
                if( stringLength(tokensInfo[contractAddress].tokenName)==0){errorNumber++;}
                tokensInfo[contractAddress].tokenSymbol = tokensInfo[contractAddress].tokenContractAddress.symbol();
                if( stringLength(tokensInfo[contractAddress].tokenSymbol)==0){errorNumber++;}
                tokensInfo[contractAddress].decimals = tokensInfo[contractAddress].tokenContractAddress.decimals();
                if( tokensInfo[contractAddress].decimals==0){errorNumber++;}
                if(errorNumber >2){ return "this is not a Standard token contract Address" ;}else{
                tokensInfo[contractAddress].isSubmitedBefore = true;
                tokensInfo[contractAddress].tokensBalance = 0;
                emit addToken(msg.sender,contractAddress,tokensInfo[contractAddress].tokenName);
                return "This token has been added";
                }

            }else{
                return "This token has already been added ";
            }
        }





        function viewTokenInfo(address contractAddress)public view returns(string memory,string memory,uint256,uint8, string[] memory) {
            require(tokensInfo[contractAddress].isSubmitedBefore == true, "token not found");
            uint256 tokenBalance;
            string [] memory poolsInfo;

            tokenBalance=tokensInfo[contractAddress].tokensBalance;
            for(uint i =0; i< (tokensInfo[contractAddress].poolsForThisToken.length);i++){
                poolsInfo[i] =_liquidityPools[tokensInfo[contractAddress].poolsForThisToken[i]].pairName;
            }//this function returns: 
            // 1- a strings its store token name
            // 2- a strings its store token symbol
            // 2- a uint: its store total liqudity avalable
            // 3- a uint:it store decimals of token
            // 4- a string arry: its store all pair of token
            return (tokensInfo[contractAddress].tokenName ,  tokensInfo[contractAddress].tokenSymbol , tokensInfo[contractAddress].tokensBalance,tokensInfo[contractAddress].decimals, poolsInfo); 
        }









// the folowing function similar to viewTokenInfo but this function return more info about token 
// but tx cost is higher
        function _viewTokenInfo(address contractAddress)public view returns(string [] memory,string [] memory) {
            require(tokensInfo[contractAddress].isSubmitedBefore == true, "token not found");
            uint256 tokenBalance;
            string [] memory tokenInfo;
            address address1;
            address address2;
            string memory poolName;
            uint256 tokensInPool;
            string [] memory poolsInfo;
            tokenBalance=tokensInfo[contractAddress].tokensBalance;

            tokenInfo[0]=string.concat("token Name:",tokensInfo[contractAddress].tokenName);

            tokenInfo[1]=string.concat("\ntoken Symbol:",tokensInfo[contractAddress].tokenSymbol);

            tokenInfo[2]=string.concat("\ndecimals:",Strings.toString(tokensInfo[contractAddress].decimals));

            tokenInfo[3]=string.concat(" \ntotal liquidity:",Strings.toString(tokenBalance), tokensInfo[contractAddress].tokenSymbol);

            tokenInfo[4]="\nnote: decimals not showed here";
    

            for(uint i =0; i< ((tokensInfo[contractAddress].poolsForThisToken.length) * 5 ); i+=5 ){
                (address1,address2) = ConvertIDToContractAddress(tokensInfo[contractAddress].poolsForThisToken[i/5]);
                if(address1 == contractAddress){
                    tokensInPool=_liquidityPools[tokensInfo[contractAddress].poolsForThisToken[i/5]].token1Amount;
                }else {
                    tokensInPool=_liquidityPools[tokensInfo[contractAddress].poolsForThisToken[i/5]].token2Amount;
                }
                poolName=_liquidityPools[tokensInfo[contractAddress].poolsForThisToken[i/5]].pairName;
                poolsInfo[i] = string.concat("pool Name:",poolName);
                poolsInfo[(i+1)]= string.concat( "\ntokens in this pool:1-",tokensInfo[address1].tokenName);
                poolsInfo[(i+2)]= string.concat("\n2-",tokensInfo[address2].tokenName);
                poolsInfo[(i+3)]=string.concat("\n",tokensInfo[contractAddress].tokenName," in this pool:", Strings.toString(tokensInPool));
                poolsInfo[(i+4)]="\nnote:decimals not showed here\n";
            }
            return (tokenInfo, poolsInfo);

        }
                function addStableCoin(address contractAddress) public onlyOwner returns(bool){
            IsStableCoin[contractAddress]=true;
            emit _addStableCoin(msg.sender,contractAddress, IERC20(contractAddress).name());
            return true;
        }
        function removeStableCoin(address contractAddress) public onlyOwner returns(bool){
            IsStableCoin[contractAddress]=false;
            emit _removeStableCoin(msg.sender,contractAddress, IERC20(contractAddress).name());
            return true;
        }
        function userLiquidityView(address userWalletAddress) view public returns( string[] memory,address[] memory,address[] memory,uint256[] memory,uint256[] memory){
            uint256 allUserPoolCount =_userLiquidity[userWalletAddress].userPools.length;
            string [] memory poolName;
            uint256 [] memory token1InPool;
            uint256 [] memory token2InPool;
            address [] memory token1ContractAddress;
            address [] memory token2ContractAddress;
            bytes memory poolId;
            for(uint i=0; i< allUserPoolCount ;i++){
                poolId =_userLiquidity[userWalletAddress].userPools[i];
                token1InPool[i] = _userLiquidity[userWalletAddress].token1Inpool[poolId];
                token2InPool[i] = _userLiquidity[userWalletAddress].token2Inpool[poolId];
                poolName [i] = _liquidityPools[poolId].pairName;
                (token1ContractAddress[i],token2ContractAddress[i]) = ConvertIDToContractAddress(poolId);
            }//this function return info about user pool
            // 1)a string contains pair name
            // 2) a address contain token1ContractAddress
            // 3) a address contain token2ContractAddress
            // 4) a uint contains token1 amuont in pair
            // 5) a uint contain token2 amuont in pair

            return (poolName ,token1ContractAddress,token2ContractAddress,token1InPool,token2InPool);
        }

        
        function _userLiquidityView(address userWalletAddress) view public returns( string[] memory,string memory){
            uint256 allUserPoolCount =_userLiquidity[userWalletAddress].userPools.length;
            string memory poolName;
            uint256 token1InPool;
            uint256 token2InPool;
            address token1ContractAddress;
            address token2ContractAddress;
            string memory token1Symbol;
            string memory token2Symbol;
            bytes memory poolId;
            string[] memory allInfo;
            for(uint i=0; i< (allUserPoolCount * 3);i+=3){
                poolId =_userLiquidity[userWalletAddress].userPools[i/3];
                token1InPool = _userLiquidity[userWalletAddress].token1Inpool[poolId];
                token2InPool = _userLiquidity[userWalletAddress].token2Inpool[poolId];
                poolName = _liquidityPools[poolId].pairName;
                (token1ContractAddress,token2ContractAddress) = ConvertIDToContractAddress(poolId);
                token1Symbol = tokensInfo[token1ContractAddress].tokenSymbol;
                token2Symbol = tokensInfo[token2ContractAddress].tokenSymbol;
                 allInfo[i] = string.concat(Strings.toString(i/3+1), ": " , poolName , ": \n ");
                 allInfo[i+1] = string.concat("pair: " ,":",Strings.toString(token1InPool),token1Symbol);
                 allInfo[i+2] = string.concat("\n",": ",Strings.toString(token2InPool),token2Symbol,"\n" );
            }
            return (allInfo , "Note:Decimals are not displayed here");
        }




        // this functions recive pool Id and send back contract address
        function ConvertIDToOneOfPairContractAddress(bytes memory poolId,uint contractToReturn) pure private returns (address){
            address  address1;
            address  address2;
            (address1,address2)=abi.decode(poolId,(address,address) );
            if(contractToReturn==1){return address1;}else{if(contractToReturn==2){ return address2;}}

        }

        function ConvertIDToContractAddress(bytes memory poolId)pure private returns(address,address){


            return abi.decode(poolId,(address,address) );
        }

        //this function calculate length of strings
            function stringLength(string memory s) private pure returns ( uint256) {
        return bytes(s).length;
        }


        function createPool(address address1,address address2) private returns(bytes memory) {
            bytes memory poolId;
            if(IsStableCoin[address1] == true){
                poolId = abi.encode(address2,address1);
            }else{
                poolId = abi.encode(address1,address2);
            }
            _liquidityPools[poolId].isPoolCreated = true;
            if(tokensInfo[address1].isSubmitedBefore == false){
                addNewToken(address1);
            }
            if(tokensInfo[address2].isSubmitedBefore== false){
                addNewToken(address2);
            }
            tokensInfo[address1].poolsForThisToken.push(poolId);
            tokensInfo[address2].poolsForThisToken.push(poolId);
            _liquidityPools[poolId].pairName = string.concat(tokensInfo[address1].tokenSymbol,"/", tokensInfo[address2].tokenSymbol);
            emit _createPair(msg.sender, ConvertIDToOneOfPairContractAddress(poolId,1),ConvertIDToOneOfPairContractAddress(poolId,2));
            return poolId;
            }

            function calculateTokenRateForAddLiqudity
            (uint256 token1Amount, uint256 token2Amount,bytes memory poolId) private view returns(uint256 ,uint256){
                    uint256 token1TenThousand;
                   uint256 token2TenThousand;
                    uint256 calculatedToken1Amount;
                   uint256 calculatedToken2Amount;

                   if( (stringLength(Strings.toString(token1Amount)) +stringLength(Strings.toString(token2Amount) )) < 78 ){
                       if(  ((token1Amount * _liquidityPools[poolId].token2Amount)/ _liquidityPools[poolId].token1Amount) > token2Amount ){
                           calculatedToken1Amount =
                           (token2Amount * _liquidityPools[poolId].token1Amount) / _liquidityPools[poolId].token2Amount;
                           calculatedToken2Amount = token2Amount;
                       } else{
                           calculatedToken2Amount=
                           ((token1Amount * _liquidityPools[poolId].token2Amount)/ _liquidityPools[poolId].token1Amount);
                           calculatedToken1Amount = token1Amount;

                       }
                       
                   }else{


                if(_liquidityPools[poolId].token1Amount > _liquidityPools[poolId].token2Amount){
                           token1TenThousand = (_liquidityPools[poolId].token1Amount *10000) / (_liquidityPools[poolId].token1Amount + 
                           _liquidityPools[poolId].token2Amount);
                           token2TenThousand = 10000 - token1TenThousand;
                       }else{
                        token2TenThousand = (_liquidityPools[poolId].token2Amount *10000) / (_liquidityPools[poolId].token1Amount + 
                           _liquidityPools[poolId].token2Amount);
                           token1TenThousand = 10000 - token2TenThousand;
                       }
                       calculatedToken2Amount = ( (token1Amount * 10000) / token1TenThousand) - token1Amount;
                       if(calculatedToken2Amount> token2Amount){
                           calculatedToken1Amount = ( (token2Amount * 10000) / token2TenThousand) - token2Amount;
                           calculatedToken2Amount = token2Amount;
                       }else{
                           calculatedToken1Amount = token1Amount;
                       }
                   }
                       return(calculatedToken1Amount,calculatedToken2Amount);
            }

            function addLiqudityProvider(uint256 calculatedToken1Amount,uint256 calculatedToken2Amount,
            address token1ContractAdress,address token2ContractAdress, bytes memory poolId )
             private returns(bool) {
                   uint256 token1BalanceBefore;
                   uint256 token2BalanceBefore;
                   uint256 token1Balanceafter;
                   uint256 token2Balanceafter;
                       token1BalanceBefore= IERC20(token1ContractAdress).balanceOf(address(this)) ;
                       token2BalanceBefore= IERC20(token2ContractAdress).balanceOf(address(this)) ;
                       IERC20(token1ContractAdress).transferFrom(msg.sender,address(this),calculatedToken1Amount);
                       IERC20(token2ContractAdress).transferFrom(msg.sender,address(this),calculatedToken2Amount);
                       token1Balanceafter= IERC20(token1ContractAdress).balanceOf(address(this)) ;
                       token2Balanceafter= IERC20(token2ContractAdress).balanceOf(address(this)) ;
                       _liquidityPools[poolId].token1Amount +=(token1Balanceafter - token1BalanceBefore);
                       _liquidityPools[poolId].token2Amount +=(token2Balanceafter - token2BalanceBefore);
                       

                       if((token1Balanceafter-token1BalanceBefore)< calculatedToken1Amount){
                           LackOfReceivedTokens[token1ContractAdress].allTokenSended = calculatedToken1Amount ;
                           LackOfReceivedTokens[token1ContractAdress].allTokenreceived = token1Balanceafter-token1BalanceBefore ;
                       }
                       if((token2Balanceafter-token2BalanceBefore)< calculatedToken2Amount){
                           LackOfReceivedTokens[token2ContractAdress].allTokenSended = calculatedToken2Amount ;
                           LackOfReceivedTokens[token2ContractAdress].allTokenreceived = token2Balanceafter-token2BalanceBefore ;

                       }
                       if(_userLiquidity[msg.sender].isPoolAddedBefore[poolId]== false){
                           _userLiquidity[msg.sender].userPools.push(poolId);
                           _liquidityPools[poolId].liquidityproviders.push(msg.sender);
                           _userLiquidity[msg.sender].isPoolAddedBefore[poolId]= true;
                       }
                       _userLiquidity[msg.sender].token1Inpool[poolId] += (token1Balanceafter - token1BalanceBefore);
                       _userLiquidity[msg.sender].token2Inpool[poolId] += (token2Balanceafter - token2BalanceBefore);
                       emit addLiquidity(msg.sender, token1ContractAdress,token2ContractAdress,calculatedToken1Amount,calculatedToken2Amount);
                       return(true);
            }



    //AddLiquidity fuction check if the pool is not created before create it and if its created before
    // will add liquidity to pool

        function AddLiquidity(address token1ContractAdress,uint256 token1Amount
        ,address token2ContractAdress,uint256 token2Amount) public returns(string memory){
            if(IERC20(token1ContractAdress).allowance(msg.sender,address(this)) >= token1Amount && 
               IERC20(token2ContractAdress).allowance(msg.sender,address(this)) >= token2Amount ){

                   uint256 calculatedToken1Amount;
                   uint256 calculatedToken2Amount;
                   
                   // the folowing code check exiting liqudity
                   if(_liquidityPools[abi.encode(token1ContractAdress,token2ContractAdress)].isPoolCreated == true){ 
                       // this code check for any pool created for this peer
                       (calculatedToken1Amount,calculatedToken2Amount)= 
                       calculateTokenRateForAddLiqudity(token1Amount,token2Amount,abi.encode(token1ContractAdress,token2ContractAdress));
                       addLiqudityProvider(calculatedToken1Amount,calculatedToken2Amount,
                       token1ContractAdress,token2ContractAdress,abi.encode(token1ContractAdress,token2ContractAdress) );

                   }else{

                        if(_liquidityPools[abi.encode(token2ContractAdress,token1ContractAdress)].isPoolCreated == true){
                           (calculatedToken1Amount,calculatedToken2Amount)=
                           calculateTokenRateForAddLiqudity(token2Amount,token1Amount,abi.encode(token2ContractAdress,token1ContractAdress));
                           addLiqudityProvider(calculatedToken1Amount,calculatedToken2Amount,
                           token2ContractAdress,token1ContractAdress,abi.encode(token2ContractAdress,token1ContractAdress) );
                        }else{
                            bytes memory poolName;
                            address token1_C;
                            address token2_C;

                            poolName = createPool(token1ContractAdress,token2ContractAdress);
                            (token1_C,token2_C)=ConvertIDToContractAddress(poolName);
                            if(token1_C ==token1ContractAdress){
                            addLiqudityProvider( token1Amount,token2Amount,token1ContractAdress,
                            token2ContractAdress,poolName);
                            }else{
                            addLiqudityProvider( token2Amount,token1Amount,token1_C,token2_C,poolName);

                            }

                        }
                   }
                   return "sucsses";

               }else{
                   return "please approve first";
               }
        }



        struct AllTokenInfo{
            string tokenName;
            string tokenSymbol;
            IERC20 tokenContractAddress;
            uint256 tokensBalance;
            uint8  decimals;
            bool isSubmitedBefore;
            bytes [] poolsForThisToken;
        }
        struct usersLiquidity{
            mapping (bytes => uint256) token1Inpool;
            bytes [] userPools;
            mapping (bytes => uint256) token2Inpool;
            mapping (bytes => bool) isPoolAddedBefore;


        }
        struct liquidityPools{
            string pairName;
            uint256 token1Amount;
            uint256 token2Amount;
            bool isPoolCreated;
            address[] liquidityproviders;
            
        }
        struct tokenWithPercentageDeficit{
            uint256 allTokenSended;
            uint256 allTokenreceived;
        }

          mapping (address => AllTokenInfo) tokensInfo;

          mapping (address => usersLiquidity) _userLiquidity; 

          mapping (bytes => liquidityPools) _liquidityPools;

          mapping (address => bool)IsStableCoin;

          mapping (address => tokenWithPercentageDeficit)LackOfReceivedTokens;

}