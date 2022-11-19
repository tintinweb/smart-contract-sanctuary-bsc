/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

// File: Bond/contracts/IERC3475.sol




pragma solidity ^0.8.0;


interface IERC3475 {

    // STRUCTURE
    /**
     * @dev Values structure of the Metadata
     */
    struct Values {
        string stringValue;
        uint uintValue;
        address addressValue;
        bool boolValue;
    }
    /**
     * @dev structure allows the transfer of any given number of bonds from one address to another.
     * @title": "defining the title information",
     * @type": "explaining the type of the title information added",
     * @description": "little description about the information stored in the bond",
     */
    struct Metadata {
        string title;
        string _type;
        string description;
    }
    /**
     * @dev structure allows the transfer of any given number of bonds from one address to another.
     * @classId is the class id of the bond.
     * @nonceId is the nonce id of the given bond class. This param is for distinctions of the issuing conditions of the bond.
     * @amount is the amount of the bond that will be transferred.
     */
    struct Transaction {
        uint256 classId;
        uint256 nonceId;
        uint256 amount;
    }

    // WRITABLES
    /**
     * @dev allows the transfer of a bond from one address to another (either single or in batches).
     * @param _from  is the address of the holder whose balance is about to decrease.
     * @param _to is the address of the recipient whose balance is about to increase.
     */
    function transferFrom(address _from, address _to, Transaction[] calldata _transactions) external;

    /**
     * @dev allows the transfer of allowance from one address to another (either single or in batches).
     * @param _from is the address of the holder whose balance about to decrease.
     * @param _to is the address of the recipient whose balance is about to increased.
     */
    function transferAllowanceFrom(address _from, address _to, Transaction[] calldata _transactions) external;

    /**
     * @dev allows issuing of any number of bond types to an address.
     * The calling of this function needs to be restricted to bond issuer contract.
     * @param _to is the address to which the bond will be issued.
     */
    function issue(address _to, Transaction[] calldata _transactions) external;

    /**
     * @dev allows redemption of any number of bond types from an address.
     * The calling of this function needs to be restricted to bond issuer contract.
     * @param _from is the address _from which the bond will be redeemed.
     */
    function redeem(address _from, Transaction[] calldata _transactions) external;

    /**
     * @dev allows the transfer of any number of bond types from an address to another.
     * The calling of this function needs to be restricted to bond issuer contract.
     * @param _from  is the address of the holder whose balance about to decrees.
     */
    function burn(address _from, Transaction[] calldata _transactions) external;

    /**
     * @dev Allows _spender to withdraw from your account multiple times, up to the amount.
     * @notice If this function is called again, it overwrites the current allowance with amount.
     * @param _spender is the address the caller approve for his bonds
     */
    function approve(address _spender, Transaction[] calldata _transactions) external;

    /**
     * @notice Enable or disable approval for a third party ("operator") to manage all of the caller's tokens.
     * @dev MUST emit the ApprovalForAll event on success.
     * @param _operator Address to add to the set of authorized operators
     * @param _approved "True" if the operator is approved, "False" to revoke approval
     */
    function setApprovalFor(address _operator, bool _approved) external;

    // READABLES
    /**
     * @dev Returns the total supply of the bond in question.
     */
    function totalSupply(uint256 _classId, uint256 _nonceId) external view returns (uint256);

    /**
     * @dev Returns the redeemed supply of the bond in question.
     */
    function redeemedSupply(uint256 _classId, uint256 _nonceId) external view returns (uint256);

    /**
     * @dev Returns the active supply of the bond in question.
     */
    function activeSupply(uint256 _classId, uint256 _nonceId) external view returns (uint256);

    /**
     * @dev Returns the burned supply of the bond in question.
     */
    function burnedSupply(uint256 _classId, uint256 _nonceId) external view returns (uint256);

    /**
     * @dev Returns the balance of the giving bond _classId and bond nonce.
     */
    function balanceOf(address _account, uint256 _classId, uint256 _nonceId) external view returns (uint256);

    /**
     * @dev Returns the JSON metadata of the classes.
     * The metadata SHOULD follow a set of structure explained later in eip-3475.md
     */
    function classMetadata(uint256 _metadataId) external view returns (Metadata memory);

    /**
     * @dev Returns the JSON metadata of the nonces.
     * The metadata SHOULD follow a set of structure explained later in eip-3475.md
     */
    function nonceMetadata(uint256 _classId, uint256 _metadataId) external view returns (Metadata memory);

    /**
     * @dev Returns the values of the given _classId.
     * the metadata SHOULD follow a set of structures explained in eip-3475.md
     */
    function classValues(uint256 _classId, uint256 _metadataId) external view returns (Values memory);

    /**
     * @dev Returns the values of given _nonceId.
     * @param _classId is the class of bonds for which you determine the nonce .
     * @param _nonceId is the nonce for which you return the value struct info
     * @param _metadataId The metadata SHOULD follow a set of structures explained in eip-3475.md
     */
    function nonceValues(uint256 _classId, uint256 _nonceId, uint256 _metadataId) external view returns (Values memory);

    /**
     * @dev Returns the information about the progress needed to redeem the bond
     * @notice Every bond contract can have its own logic concerning the progress definition.
     * @param _classId The class of  bonds.
     * @param _nonceId is the nonce of bonds for finding the progress.
     */
    function getProgress(uint256 _classId, uint256 _nonceId) external view returns (uint256 progressAchieved, uint256 progressRemaining);

    /**
     * @notice Returns the amount which spender is still allowed to withdraw from _owner.
     * @param _owner is the address whose owner allocates some amount to the _spender address.
     * @param _classId is the _classId of bond .
     * @param _nonceId is the nonce corresponding to the class for which you are approving the spending of total amount of bonds.
     */
    function allowance(address _owner, address _spender, uint256 _classId, uint256 _nonceId) external view returns (uint256);

    /**
     * @notice Queries the approval status of an operator for a given owner.
     * @param _owner is the current holder of the bonds for  all classes / nonces.
     * @param _operator is the address which is  having access to the bonds of _owner for transferring
     * Returns "true" if the operator is approved, "false" if not
     */
    function isApprovedFor(address _owner, address _operator) external view returns (bool);

    // EVENTS
    /**
     * @notice MUST trigger when tokens are transferred, including zero value transfers.
     */
    event Transfer(address indexed _operator, address indexed _from, address indexed _to, Transaction[] _transactions);

    /**
     * @notice MUST trigger when tokens are issued
     */
    event Issue(address indexed _operator, address indexed _to, Transaction[] _transactions);

    /**
     * @notice MUST trigger when tokens are redeemed
     */
    event Redeem(address indexed _operator, address indexed _from, Transaction[] _transactions);

    /**
     * @notice MUST trigger when tokens are burned
     */
    event Burn(address indexed _operator, address indexed _from, Transaction[] _transactions);

    /**
     * @dev MUST emit when approval for a second party/operator address to manage all bonds from a classId given for an owner address is enabled or disabled (absence of an event assumes disabled).
     */
    event ApprovalFor(address indexed _owner, address indexed _operator, bool _approved);

    // IBO specific
    struct BondParameters {
        address LPToken;
        address projectWallet;
        uint256 issuanceDate;
        uint256 prepaymentPenalty;
        uint256 maturityDate;
        uint256 maturityProfitDate;
    }

    function createBond(
        address token,  // project token is used as classId
        BondParameters calldata p // parameters of bond
    ) external returns (uint256 classId, uint256 nonceId);

    // return maximum amount of pairToken is allowed to redeem. (-1) means "no limit"
    function getLimit(uint256 classId, uint256 nonceId, address user) external view returns(int256);

    event CreateBond(uint256 classId, uint256 nonceId, address token, BondParameters parameters);
}

// File: Bond/contracts/SecureFloor.sol



pragma solidity 0.8.17;




// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        // bytes4(keccak256(bytes('approve(address,uint256)')));

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));

        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');

    }



    function safeTransfer(address token, address to, uint value) internal {

        // bytes4(keccak256(bytes('transfer(address,uint256)')));

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));

        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');

    }



    function safeTransferFrom(address token, address from, address to, uint value) internal {

        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));

        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');

    }



    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));

        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');

    }

}



interface IERC20 {

    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

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

abstract contract Ownable {

    address internal _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    /*

    constructor () {

        _owner = msg.sender;

        emit OwnershipTransferred(address(0), msg.sender);

    }

    */



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

        require(owner() == msg.sender, "Ownable: caller is not the owner");

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

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     * Can only be called by the current owner.

     */

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



interface ISwap {

    function claimFee() external returns (uint256); // returns feeAmount

    function getColletedFees() external view returns (uint256); // returns feeAmount

}



interface IRouter {

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

    function swapExactTokensForTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external returns (uint[] memory amounts);



    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)

        external

        payable

        returns (uint[] memory amounts);



    // Derex functions

    // Create pair with options 

    function createPair(

        address tokenA,

        address tokenB,

        uint amountA,

        uint amountB,

        address to,

        uint32[8] memory vars, 

        bool isPrivate, // is private pool

        address protectedToken, // which token should be protected by secure floor, if address(0) then without secure floor        

        uint32[2] memory voteVars // [0] - voting delay, [1] - minimal level for proposal in percentage with 2 decimals i.e. 100 = 1%

    ) external returns (uint liquidity);



    function createPairETH(

        address token,

        uint amountToken,

        address to,

        uint32[8] memory vars, 

        bool isPrivate, // is private pool

        address protectedToken, // which token should be protected by secure floor, if address(0) then without secure floor        

        uint32[2] memory voteVars // [0] - voting delay, [1] - minimal level for proposal in percentage with 2 decimals i.e. 100 = 1%

    ) external payable returns (uint liquidity);    

}



interface IDexFactory {

    function getPair(address tokenA, address tokenB) external view returns (address pair);

}



interface IDexPair {

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

}



contract SecureFloor is Ownable {

    using TransferHelper for address;



    // default vars for Derex poo creation

    uint32[8] private _vars; // timeFrame, maxDump0, maxDump1, maxTxDump0, maxTxDump1, coefficient, minimalFee, periodMA

    //timeFrame = 1 days;  // during this time frame rate of reserve1/reserve0 should be in range [baseLinePrice0*(1-maxDump0), baseLinePrice0*(1+maxDump1)]

    //maxDump0 = 10000;   // maximum allowed dump (in percentage with 2 decimals) of reserve1/reserve0 rate during time frame relatively the baseline

    //maxDump1 = 10000;   // maximum allowed dump (in percentage with 2 decimals) of reserve0/reserve1 rate during time frame relatively the baseline

    //maxTxDump0 = 10000; // maximum allowed dump (in percentage with 2 decimals) of token0 price per transaction

    //maxTxDump1 = 10000; // maximum allowed dump (in percentage with 2 decimals) of token1 price per transaction

    //coefficient = 10000; // coefficient (in percentage with 2 decimals) to transform price growing into fee. ie

    //minimalFee = 5;   // Minimal fee percentage (with 2 decimals) applied to transaction. I.e. 5 = 0.05%

    //periodMA = 45 minutes;  // MA period in seconds

    uint32[2] private _voteVars;



    address public dumperShieldFactory;

    address public pdoFactory;

    address public derexRouter;

    address public bondContract;



    struct FeeParams {

        uint8 feeType;  // 0 - free, 1 - 5% to DumperShield, 2 - 10% into PDO

        // DumperShield params

        address router; // dex router where exist pool "token-WETH" (token to native coin)

        uint64 dsReleaseTime;   // Epoch time (in seconds) when tokens will be unlocked in dumper shield. 0 if no DS needed

        // PDO params

        uint64 stakingPeriod; // number of days (0 means no staking)

        uint64 stakingAPY; // the percentage of APY with 4 decimals

        address licensee; //    Licensee address who bring the client (0 if no licensee)

    }



    struct VestingParams {

        // vesting principal

        uint64 cliffDate;   // epoch timestamp of cliff date (in seconds), if there isn't cliff then 0

        uint32 gradedPeriod; // period in seconds. If graded vesting, then release every 'period'

        uint32 gradedPortionPercent;    // percent to release every period

        // vesting profits

        uint64 cliffProfitDate;   // epoch timestamp of cliff date (in seconds), if there isn't cliff then 0

        uint32 gradedProfitPeriod; // period in seconds. If graded vesting, then release every 'period'

        uint32 gradedProfitPortionPercent;    // percent to release every period

        uint32 prepaymentPenalty;   // percentage of initial penalty. During the time penalty will decrease

    }



    struct Parameters {

        // step 1

        address token;  //  project token

        address pairToken;  // token that should be paid by users to add pool liquidity. Address(1) if native coin (BNB)

        //address dexRouter;  // address of DEX router where is pool "token-pairToken". If 0, then create new pool with secure floor

        uint64  startDate;  // Epoch time (in seconds) when IBO will be started.

        uint64  endDate;    // Epoch time (in seconds) when IBO will be closed.

        //bool leftoverBurn;  // if true - burn leftover, false - return to project

        // step 2

        VestingParams vestingParams;

        // step 3

        uint256 supplyAmount;  // amount of tokens that project supply

        uint256 targetAmount;  // amount of pairTokens, used to calculate ratio for addLiquidity (supplyAmount:targetAmount)

        FeeParams feeParams;

        // limits

        uint256 minInvestment; // min investment in "pairToken"

        uint256 maxInvestment; // max investment in "pairToken"

    }



    struct PoolParams {

        address poolAddress;

        address projectWallet;

        uint256 spentTokens;

        uint256 totalRaisedPairTokens;  // amount of pair tokens received during IBO

    }



    mapping(uint256 => mapping(uint256 => Parameters)) public parameters; // classId => nonceId => Parameters

    mapping(uint256 => mapping(uint256 => PoolParams)) public poolParams; // classId => nonceId => poolParams



    event CreateOffer(address creator, Parameters p, PoolParams pp, uint256 classId, uint256 nonceId);

    event BuyBond(address buyer, uint256 classId, uint256 nonceId, uint256 bondAmounts, PoolParams pp);

    event WithdrawProjectTokens(uint256 classId, uint256 nonceId, uint256 amount);

    event AddProjectTokens(uint256 classId, uint256 nonceId, uint256 amount);





    function initialize() public {

        require(_owner == address(0));

        _owner = msg.sender;

        emit OwnershipTransferred(address(0), msg.sender);

        _vars = [1 days, 10000, 10000, 10000, 10000, 10000, 5, 45 minutes];

        _voteVars = [uint32(1 days), 100];

        //super.initialize();

    }



    function createOffer(Parameters calldata p) external payable returns(uint256 classId, uint256 nonceId) {

        uint256 liquidity;

        // create pool with secure floor

        {

        IERC3475.BondParameters memory params;

        uint256 oneToken = 10**(IERC20(p.token).decimals()); // one token with decimals

        {

        p.token.safeTransferFrom(msg.sender, address(this), p.supplyAmount);

        require(oneToken < p.supplyAmount, "Not enough tokens");

        uint256 price = p.targetAmount * oneToken / p.supplyAmount;

        if (p.pairToken == address(1)) {

            require(msg.value == price, "wrong msg.value");

            p.token.safeApprove(derexRouter, oneToken);

            liquidity = IRouter(derexRouter).createPairETH{value: price}(p.token, oneToken, address(this), _vars, true, p.token, _voteVars);

            params.LPToken = IDexFactory(IRouter(derexRouter).factory()).getPair(p.token, IRouter(derexRouter).WETH());

        } else {

            p.pairToken.safeTransferFrom(msg.sender, address(this), price);

            p.pairToken.safeApprove(derexRouter, price);

            p.token.safeApprove(derexRouter, type(uint256).max);    // approve maximum amount at once

            {

            liquidity = IRouter(derexRouter).createPair(p.token, p.pairToken, oneToken, price, address(this), _vars, true, p.token, _voteVars);

            }

            params.LPToken = IDexFactory(IRouter(derexRouter).factory()).getPair(p.token, p.pairToken);

        }

        }

        params.projectWallet = msg.sender;

        params.issuanceDate = p.endDate;

        params.prepaymentPenalty = p.vestingParams.prepaymentPenalty;

        params.maturityDate = p.vestingParams.cliffDate;

        params.maturityProfitDate = p.vestingParams.cliffProfitDate;

        // get classId and nonceId

        (classId, nonceId) = IERC3475(bondContract).createBond(p.token, params);

        poolParams[classId][nonceId].spentTokens = oneToken;

        poolParams[classId][nonceId].poolAddress = params.LPToken;

        poolParams[classId][nonceId].projectWallet = msg.sender;

        parameters[classId][nonceId] = p;

        // issue bond to creator

        liquidity--;   // left 1 wei of token to be able addLiquidity to private pool

        params.LPToken.safeApprove(bondContract, liquidity);

        }

        {

        IERC3475.Transaction[] memory _transactions = new IERC3475.Transaction[](1);

        _transactions[0] = IERC3475.Transaction(classId, nonceId, liquidity);

        IERC3475(bondContract).issue(msg.sender, _transactions);

        }

        emit CreateOffer(msg.sender, p, poolParams[classId][nonceId], classId, nonceId);

    }

    

    // Buy bond

    function buyBond(uint256 classId, uint256 nonceId, uint256 payAmount) external payable {

        Parameters storage p = parameters[classId][nonceId];

        PoolParams storage pp = poolParams[classId][nonceId];

        require(block.timestamp >= p.startDate && block.timestamp < p.endDate, "IBO isn't opened");

        address token0 = IDexPair(pp.poolAddress).token0();

        (uint112 reserve0, uint112 reserve1,) = IDexPair(pp.poolAddress).getReserves();

        require(reserve0 != 0 && reserve1 != 0, "Wrong reserves");

        if (p.token != token0) (reserve0, reserve1) = (reserve1, reserve0); // reserve0 of project token, reserve1 of pair token

        uint256 tokenAmount = payAmount * reserve0 / reserve1;

        pp.spentTokens += tokenAmount;

        require(pp.spentTokens <= p.supplyAmount, "Not enough supply");

        p.token.safeApprove(derexRouter, tokenAmount);

        uint256 bondAmounts;

        if (p.pairToken == address(1)) {

            require(msg.value == payAmount, "wrong msg.value");

            (,,bondAmounts) = IRouter(derexRouter).addLiquidityETH{value: payAmount}(p.token, tokenAmount, 0, 0, address(this), block.timestamp);

        } else {

            p.pairToken.safeTransferFrom(msg.sender, address(this), payAmount);

            p.pairToken.safeApprove(derexRouter, payAmount);

            (,,bondAmounts) = IRouter(derexRouter).addLiquidity(p.token, p.pairToken, tokenAmount, payAmount, 0, 0, address(this), block.timestamp);

        }

        pp.totalRaisedPairTokens += payAmount;

        // issue bond to buyer

        {

        IERC3475.Transaction[] memory _transactions = new IERC3475.Transaction[](1);

        _transactions[0] = IERC3475.Transaction(classId, nonceId, bondAmounts);

        IERC3475(bondContract).issue(msg.sender, _transactions);

        }

        emit BuyBond(msg.sender, classId, nonceId, bondAmounts, pp);

    }



    // Allow project wallet withdraw unspent tokens

    function withdrawProjectTokens(uint256 classId, uint256 nonceId, uint256 amount) external {

        Parameters storage p = parameters[classId][nonceId];

        PoolParams storage pp = poolParams[classId][nonceId];

        require(msg.sender == pp.projectWallet, "Only bond creator can withdraw");

        require(amount <= p.supplyAmount - pp.spentTokens, "Not enough supply");

        p.pairToken.safeTransfer(msg.sender, amount);

        p.supplyAmount -= amount;

        emit WithdrawProjectTokens(classId, nonceId, amount);

    }



    // Allow project wallet to add more tokens to supply

    function addProjectTokens(uint256 classId, uint256 nonceId, uint256 amount) external {

        Parameters storage p = parameters[classId][nonceId];

        PoolParams storage pp = poolParams[classId][nonceId];

        require(msg.sender == pp.projectWallet, "Only bond creator can withdraw");

        p.pairToken.safeTransferFrom(msg.sender, address(this), amount);

        p.supplyAmount += amount;

        emit AddProjectTokens(classId, nonceId, amount);

    }



    function setDumperShieldFactory(address _dumperShieldFactory) external onlyOwner {

        dumperShieldFactory = _dumperShieldFactory;

    }



    function setPdoFactory(address _pdoFactory) external onlyOwner {

        pdoFactory = _pdoFactory;

    }



    function setDerex(address _derexRouter) external onlyOwner {

        derexRouter = _derexRouter;

    }



    function setDerexVars(uint32[8] calldata _derexVars) external onlyOwner {

        _vars = _derexVars;

    }



    function getDerexVars() external view returns(uint32[8] memory) {

        return _vars;

    }



    function setDerexVoteVars(uint32[2] calldata _derexVoteVars) external onlyOwner {

        _voteVars = _derexVoteVars;

    }



    function getDerexVoteVars() external view returns(uint32[2] memory) {

        return _voteVars;

    }



    function setBondContract(address _bondContract) external onlyOwner {

        require(_bondContract != address(0));

        bondContract = _bondContract;

    }



}