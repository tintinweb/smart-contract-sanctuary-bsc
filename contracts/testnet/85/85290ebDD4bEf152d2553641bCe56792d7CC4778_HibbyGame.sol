// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./IHibbyToken.sol";
import "./IHibbyStorage.sol";
// import "hardhat/console.sol";

pragma solidity ^0.8.4;

contract HibbyGame is Ownable{

    using Address for address;

    IHibbyToken token;
    IHibbyStorage store; 
    IUniswapV2Router02 router;

    uint256 public totalHibbyChains;

    uint256 public priceToJoinHibby = 5*10**18;

    uint88 public reflection;

    struct User{

        uint16 currentParticipation;
        uint256[] hibbyIds;
        bytes32[] currentReferrals; 

    }

    mapping(address => User) public user;

    struct HibbyUser{

        address inviter;            // address of the user theat invite in the chain
        bool rewardClaimed;         // User is claimed his reward or not
        uint88 claimedFees;         // How much he claimed in this chain
        uint88 unclaimedFees;       // How much he did not claimed
        uint88 totalParticipations; // Total participants that join by users refferal
        uint32 chainPosition;       // Position to the chain
        bytes32 userToReferral;     // User to Referral

    }
    
    mapping(address => mapping(uint256 => HibbyUser)) public hibbyUser;

    mapping(bytes32 => address) public referralToUser;

    mapping(bytes32 => uint256) public referralToHibby;
    
    struct Hibby {

        uint256 id;                 // Unique id for the hibby
        address creator;            // Hibby creator
        string title;               // Message that creator give
        bool status;                // Hibby is alive or died
        uint88 accumulatedFees;     // Fees that accumulated through out the game
        uint88 creationDate;        // Hibby creation date
        uint88 endDate;             // Hibby end date
        uint88 lastParticipant;     // Last participant time stamp
        uint88 toBurn;              // Total fee collected to burn
        uint32 chainLength;         // Chain Length of Hibby
        mapping(uint32 => address) chainToUser; // Address at specific id

    }

    mapping(uint256 => Hibby) public hibby; 

    uint256[] public aliveHibbies; 

    uint public totalAliveHibby;
    
    constructor(address _token, address _store, address _router){

        token = IHibbyToken(_token);
        store = IHibbyStorage(_store);
        router = IUniswapV2Router02(_router);
    
    }

    // Function to output the price of the Hibby token with respect to input BUSD token
    function getPrice() public view returns(uint256){
       
        address[] memory path = new address[](2);
        path[1] = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
        path[0] = 0xCabB4BDFC71974c747dA2F2147982207556dead1;

        uint256[] memory _price = new uint256[](2);
        _price = router.getAmountsIn(priceToJoinHibby, path);
        return _price[0];
    }

    function _checkPriceIsCorrect(uint256 _amountToken) internal view returns(bool){
        
        uint256 price = getPrice();

        if((_amountToken >= price - (price*1)/100) &&
           (_amountToken <= price + (price*1)/100)){
               return true;
           }
        
        return false;
    }

    // Function used to create the new hibbh chain
    function create(uint88 _amount, string memory _title) external {
                        
        // Creating New Hibby Data
        address _msgAddress = _msgSender();

        //Taking the price of the current hibby token      
       
        require(_checkPriceIsCorrect(_amount), "Amount of the token is Invalid");
        
        token.transferFrom(_msgAddress, address(this), _amount);

        totalHibbyChains++;
        
        // Creating the hibby chain data 
        hibby[totalHibbyChains].id = totalHibbyChains;
        hibby[totalHibbyChains].creator = _msgAddress;
        hibby[totalHibbyChains].title = _title;
        hibby[totalHibbyChains].status = true;
        hibby[totalHibbyChains].accumulatedFees += _amount - (_amount*reflection)/100;
        hibby[totalHibbyChains].creationDate = uint88(block.timestamp);
        hibby[totalHibbyChains].lastParticipant = uint88(block.timestamp);
        hibby[totalHibbyChains].toBurn = _amount - (_amount*reflection)/100;
        uint32 chainLength = hibby[totalHibbyChains].chainLength += 1;
        hibby[totalHibbyChains].chainToUser[chainLength] = _msgAddress;
              
        aliveHibbies.push(totalHibbyChains);
        totalAliveHibby++;
        
        //Create HibbyUser Data    
        hibbyUser[_msgAddress][totalHibbyChains].chainPosition = chainLength;
        
        bytes32 referral = hibbyUser[_msgAddress][totalHibbyChains].userToReferral = keccak256(abi.encode(_msgAddress, totalHibbyChains, chainLength, block.timestamp));

        user[_msgAddress].currentParticipation++;
        user[_msgAddress].hibbyIds.push(totalHibbyChains);
        user[_msgAddress].currentReferrals.push(referral);
 
        //Updating all the mapping  
        referralToUser[referral] = _msgAddress;
        referralToHibby[referral] = totalHibbyChains; 
               
    }
    
    // Function to return all the referral link of an address
    function allReferralWithChainId() external view returns (bytes32[] memory, uint256[] memory){
        return (user[_msgSender()].currentReferrals, user[_msgSender()].hibbyIds);
    }

    // Function to return the referral link with respect to chain Id
    function referralFromChainId(uint256 _chainId) external view returns(bytes32){
        return hibbyUser[_msgSender()][_chainId].userToReferral;
    } 

    // Function to join the currently running hibby by the referral link
    function join(uint88 _amount, bytes32 _referral) external {
        
        uint256 _died = findOneDiedHibby();

        if(_died > 0){
            burn(_died);
        }
        address _msgAddress = _msgSender();

        require(referralToUser[_referral] != address(0), "referal is invalid or Hibby is died");
        
        uint256 hibbyId = referralToHibby[_referral];

        require(hibby[hibbyId].status, "Hibby is died");
        
        // User address of the referral link  
        address referralAddress = hibbyUser[_msgAddress][hibbyId].inviter = referralToUser[_referral];

        if( hibby[hibbyId].lastParticipant + 1 days <=  block.timestamp){
            hibby[hibbyId].status = false;
            hibby[hibbyId].endDate = uint88(block.timestamp);
            return;
        }
        
        require(_checkPriceIsCorrect(_amount), "Amount of the token is Invalid");
               
        token.transferFrom(_msgAddress, address(this), _amount);

        hibbyUser[referralAddress][hibbyId].totalParticipations++;

        _amount = _amount - ((_amount * reflection)/100);
        uint88 remainFee = _amount;
        
        //Updating hibby Data
        hibby[hibbyId].accumulatedFees += remainFee;
        hibby[hibbyId].lastParticipant = uint88(block.timestamp);
        uint32 chainLength = hibby[hibbyId].chainLength += 1;
        hibby[hibbyId].chainToUser[chainLength] = _msgAddress;

        // Creating Hibby User Data
        hibbyUser[_msgAddress][hibbyId].inviter = referralAddress;
        hibbyUser[_msgAddress][hibbyId].chainPosition = chainLength;
        bytes32 referral = hibbyUser[_msgAddress][hibbyId].userToReferral = keccak256(abi.encode(_msgAddress, hibbyId, chainLength, block.timestamp));

        //Updateing the mapping
        referralToUser[referral] = _msgAddress;
        user[_msgAddress].currentParticipation++;
        user[_msgAddress].hibbyIds.push(hibbyId);
        user[_msgAddress].currentReferrals.push(referral);

        referralToHibby[referral] = hibbyId;

        uint88 rewardFee = (_amount*10)/100;
        address hibbyCreator = hibby[hibbyId].creator;
        
        if(hibbyUser[hibbyCreator][hibbyId].rewardClaimed == false){
            hibbyUser[hibbyCreator][hibbyId].unclaimedFees += rewardFee;
            remainFee -= rewardFee;
        }       
        uint88 i = 40;        
        while(i > 0){
            rewardFee = (_amount*i)/100;
            if(referralAddress == hibbyCreator){
                if(hibbyUser[referralAddress][hibbyId].rewardClaimed == false){
                    hibbyUser[referralAddress][hibbyId].unclaimedFees += rewardFee;
                    remainFee -= rewardFee;
                    break;
                }
                else{
                    break;
                }
                
            } else if(hibbyUser[referralAddress][hibbyId].rewardClaimed == false){
                hibbyUser[referralAddress][hibbyId].unclaimedFees += rewardFee;
                remainFee -= rewardFee;
                referralAddress = hibbyUser[referralAddress][hibbyId].inviter;

                i = i/2;
            }
            else{
                referralAddress = hibbyUser[referralAddress][hibbyId].inviter;
            }
        }
        hibby[hibbyId].toBurn += remainFee;
        return;
    }
    
    //Function to claim the reward if the hibby is currently running
    function claimRewardByChainId(uint256 _chainId) public {
        address _msgAddress = _msgSender();
                
        require(hibby[_chainId].lastParticipant + 1 days  >=  block.timestamp, "Hibby is died");
        require(!hibbyUser[_msgAddress][_chainId].rewardClaimed, "You already claimed your reward");
        hibbyUser[_msgAddress][_chainId].rewardClaimed = true;
        
        store.updateUser(_msgAddress, hibbyUser[_msgAddress][_chainId].unclaimedFees, 0);
        token.transfer(_msgAddress,hibbyUser[_msgAddress][_chainId].unclaimedFees);
        
        hibbyUser[_msgAddress][_chainId].claimedFees = hibbyUser[_msgAddress][_chainId].unclaimedFees;
        hibbyUser[_msgAddress][_chainId].unclaimedFees = 0;
    }

    // Function to check the status of the hibby by the referral link
    function checkHibby(bytes32 _referral) external view returns(uint256, bool){
                
        uint256 hibbyId = referralToHibby[_referral];
        if(block.timestamp - hibby[hibbyId].lastParticipant >= 1 days){
            return (hibbyId, false);
        }
        return (hibbyId, hibby[hibbyId].status);
    }

    // Function to get all the player of the hibbyId
    function getHibbyAddressById(uint _hibbyId) external view returns(address[] memory){
        uint _chainLength = hibby[_hibbyId].chainLength;
        address[] memory _players = new address[](_chainLength); 
        for(uint32 i = 1; i <= _chainLength; i++){
            _players[i] = hibby[_hibbyId].chainToUser[i];
        }
        return _players;
    }

    // Function to burn the hibby by the index value
    function burn(uint _index) public  {
        uint256 hibbyId = aliveHibbies[_index];
        
        require((hibby[hibbyId].lastParticipant + 1 days <=  block.timestamp) ||
                (hibby[hibbyId].status == false), "Hibby is alive");
                
            token.burn(hibby[hibbyId].toBurn);
                        
            (, uint248 _historyIndex) = store.getGameData(0);
            address _creator = hibby[hibbyId].creator;
            
            //Storing the data to the storage contract 
            store.updateGameHistory(
                hibbyId,
                0,
                _historyIndex,
                _creator,
                hibby[hibbyId].title,
                hibby[hibbyId].accumulatedFees,
                hibby[hibbyId].creationDate,
                hibby[hibbyId].lastParticipant + 1 days,
                hibby[hibbyId].chainLength
                );
            
            address[] memory _gameWinners = new address[](1);
            _gameWinners[0] = _creator;
            uint88[] memory _gamePrizes = new uint88[](1);
            _gamePrizes[0] = hibbyUser[_creator][hibbyId].claimedFees;

            store.updateGameHistoryWinner(0, _historyIndex, _gameWinners, _gamePrizes);
            address _user;
            uint i;
            uint k;
            uint _idsLength;
            for(uint32 j = 1 ; j <= hibby[hibbyId].chainLength ; j++){
                _user = hibby[hibbyId].chainToUser[j];
                if( hibbyUser[_user][hibbyId].unclaimedFees > 0 ){
                    
                    //Storing the data to the storage contract
                    store.updateUser(_user, 0,  hibbyUser[_user][hibbyId].unclaimedFees); 
                    _idsLength = i = user[_user].hibbyIds.length;
                   
                    while(i > 0){
                        
                        k = i -1;

                        if(user[_user].hibbyIds[k] == hibbyId){
                           
                            user[_user].hibbyIds[k] = user[_user].hibbyIds[_idsLength - 1];
                            user[_user].currentReferrals[k] = user[_user].currentReferrals[_idsLength -1];
                            user[_user].hibbyIds.pop();
                            user[_user].currentReferrals.pop();
                            user[_user].currentParticipation--;

                        }                                               
                        i--;
                    }
                    
                }
                delete hibbyUser[_user][hibbyId];
            }
            delete hibby[hibbyId];

            uint lastIndex = aliveHibbies.length -1;
            aliveHibbies[_index] = aliveHibbies[lastIndex];
            aliveHibbies.pop();
            totalAliveHibby--;
    }

    // Function to check how many hibby has died
    function findAllDiedHibby() public view returns(uint256[] memory ){
        uint i = aliveHibbies.length;
        uint256 hibbyId;
        uint count;
        uint256[] memory died = new uint256[](i);
        if(i == 0) return died;
        
        while(i > 0){
            hibbyId = aliveHibbies[i-1];
            if((hibby[hibbyId].lastParticipant + 1 days)  <=  block.timestamp) {  
                died[count] = i - 1;
                count++;
            }
            i--;
        }
        return died;
    }

    // Function to check how many hibby has died
    function findOneDiedHibby() public view returns(uint){
        uint i = aliveHibbies.length;
        uint256 hibbyId;
        uint256 died;
        if(i == 0) return died;
        
        while(i > 0){
            hibbyId = aliveHibbies[i-1];
            if((hibby[hibbyId].lastParticipant + 1 days)  <=  block.timestamp) {  
                died = i - 1; 
                break;
            }
            i--;
        }
        return died;
    }

    function changeTokenAddress(address _token) external onlyOwner {
        token = IHibbyToken(_token);
    }

    function changeStorageAddress(address _store) external onlyOwner {
        store = IHibbyStorage(_store);
    }

    function changeRouterAddress(address _router) external onlyOwner {
        router = IUniswapV2Router02(_router);
    }

    function changePriceToJoinHibby(uint _price) external onlyOwner {
        priceToJoinHibby = _price;
    }
           
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IHibbyToken {
    
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

    function burn(uint amount) external;

    function burnFrom(address account, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IHibbyStorage {

function getUser(address _account) external view returns(uint88, uint88);

function getGameData(uint8 _gameIndex) external view returns(string memory, uint248);

function updateUser(address _account, uint88 _totalRewards, uint88 _unclaimedReward) external;

function updateGameHistory(
    uint256 _gameHistoryId,
    uint8 _gameIndex,
    uint248 _historyIndex,
    address _gameCreator,
    string memory _gameWorking,
    uint88 _gameAccumlatedFees,
    uint88 _gameStardDate,
    uint88 _gameEndDate,
    uint88 _gameTotalParticipants
) external;

function updateGameHistoryWinner(uint8 _gameIndex, uint248 _historyIndex, address[] calldata _gameWinners, uint88[] calldata _gamePrizes) external;


}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}