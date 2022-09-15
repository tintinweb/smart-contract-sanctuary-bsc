/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

// File: secure_floor/contracts/IERC3475.sol




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
}

// File: secure_floor/contracts/ERC3475.sol



pragma solidity ^0.8.0;


contract ERC3475 is IERC3475 {
    /**
     * @notice this Struct is representing the Nonce properties as an object
     */
    struct Nonce {
        mapping(uint256 => IERC3475.Values) _values;

        // stores the values corresponding to the dates (issuance and maturity date).
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;

        // supplies of this nonce
        uint256 _activeSupply;
        uint256 _burnedSupply;
        uint256 _redeemedSupply;
    }

    /**
     * @notice this Struct is representing the Class properties as an object
     *         and can be retrieved by the classId
     */
    struct Class {
        mapping(uint256 => IERC3475.Values) _values;
        mapping(uint256 => IERC3475.Metadata) _nonceMetadatas;
        mapping(uint256 => Nonce) _nonces;
    }

    mapping(address => mapping(address => bool)) _operatorApprovals;

    // from classId given
    mapping(uint256 => Class) internal _classes;
    mapping(uint256 => IERC3475.Metadata) _classMetadata;

    /**
     * @notice Here the constructor is just to initialize a class and nonce,
     * in practice, you will have a function to create a new class and nonce
     * to be deployed during the initial deployment cycle
     */
//    constructor() {
    //function initialize() internal {
        /*
        // define "symbol of the class";
        _classMetadata[0].title = "symbol";
        _classMetadata[0]._type = "string";
        _classMetadata[0].description = "symbol of the class";
        _classes[0]._values[0].stringValue = "DBIT Fix 6M";

        _classMetadata[1].title = "symbol";
        _classMetadata[1]._type = "string";
        _classMetadata[1].description = "symbol of the class";
        _classes[1]._values[0].stringValue = "DBIT Fix test Instantaneous";

        // define "period of the class";
        _classMetadata[5].title = "period";
        _classMetadata[5]._type = "int";
        _classMetadata[5].description = "details about issuance and redemption time";

        // define the maturity time period  (for the test class).
        _classes[0]._values[5].uintValue = 10;
        _classes[1]._values[5].uintValue = 1;

        // write the time of maturity to nonce values, in other implementation, a create nonce function can be added
        _classes[0]._nonces[0]._values[0].uintValue = block.timestamp + 180 days;
        _classes[0]._nonces[1]._values[0].uintValue = block.timestamp + 181 days;
        _classes[0]._nonces[2]._values[0].uintValue = block.timestamp + 182 days;

        // test for review the instantaneous class
        _classes[1]._nonces[0]._values[0].uintValue = block.timestamp + 1;
        _classes[1]._nonces[1]._values[0].uintValue = block.timestamp + 2;
        _classes[1]._nonces[2]._values[0].uintValue = block.timestamp + 3;

        // define "maturity of the nonce";
        _classes[0]._nonceMetadatas[0].title = "maturity";
        _classes[0]._nonceMetadatas[0]._type = "int";
        _classes[0]._nonceMetadatas[0].description = "maturity date in integer";
        _classes[1]._nonceMetadatas[0].title = "maturity";
        _classes[0]._nonceMetadatas[0]._type = "int";
        _classes[1]._nonceMetadatas[0].description = "maturity date in integer";

        // defining the value status
        _classes[0]._nonces[0]._values[0].boolValue = true;
        _classes[0]._nonces[1]._values[0].boolValue = true;
        _classes[0]._nonces[2]._values[0].boolValue = true;
        */
    //}

    // WRITABLES
    function transferFrom(
        address _from,
        address _to,
        Transaction[] calldata _transactions
    ) public virtual override {
        require(
            _from != address(0),
            "ERC3475: can't transfer from the zero address"
        );
        require(
            _to != address(0),
            "ERC3475:use burn() instead"
        );
        require(
            msg.sender == _from ||
            isApprovedFor(_from, msg.sender),
            "ERC3475:caller-not-owner-or-approved"
        );
        uint256 len = _transactions.length;
        for (uint256 i = 0; i < len; i++) {
            _transferFrom(_from, _to, _transactions[i]);
        }
        emit Transfer(msg.sender, _from, _to, _transactions);
    }

    function transferAllowanceFrom(
        address _from,
        address _to,
        Transaction[] calldata _transactions
    ) public virtual override {
        require(
            _from != address(0),
            "ERC3475: can't transfer allowed amt from zero address"
        );
        require(
            _to != address(0),
            "ERC3475: use burn() instead"
        );
        uint256 len = _transactions.length;
        for (uint256 i = 0; i < len; i++) {
            require(
                _transactions[i].amount <= allowance(_from, msg.sender, _transactions[i].classId, _transactions[i].nonceId),
                "ERC3475:caller-not-owner-or-approved"
            );
            _transferAllowanceFrom(msg.sender, _from, _to, _transactions[i]);
        }
        emit Transfer(msg.sender, _from, _to, _transactions);
    }


    function issue(address _to, Transaction[] calldata _transactions)
    external
    virtual
    override
    {
        /*
        uint256 len = _transactions.length;
        for (uint256 i = 0; i < len; i++) {
            require(
                _to != address(0),
                "ERC3475: can't issue to the zero address"
            );
            _issue(_to, _transactions[i]);
        }
        */
        emit Issue(msg.sender, _to, _transactions);
    }

    function redeem(address _from, Transaction[] calldata _transactions)
    external
    virtual
    override
    {
        require(
            _from != address(0),
            "ERC3475: can't redeem from the zero address"
        );
        uint256 len = _transactions.length;
        for (uint256 i = 0; i < len; i++) {
            (, uint256 progressRemaining) = getProgress(
                _transactions[i].classId,
                _transactions[i].nonceId
            );
            require(
                progressRemaining == 0,
                "ERC3475 Error: Not redeemable"
            );
            _redeem(_from, _transactions[i]);
        }
        emit Redeem(msg.sender, _from, _transactions);
    }

    function burn(address _from, Transaction[] calldata _transactions)
    external
    virtual
    override
    {
        require(
            _from != address(0),
            "ERC3475: can't burn from the zero address"
        );
        require(
            msg.sender == _from ||
            isApprovedFor(_from, msg.sender),
            "ERC3475: caller-not-owner-or-approved"
        );
        uint256 len = _transactions.length;
        for (uint256 i = 0; i < len; i++) {
            _burn(_from, _transactions[i]);
        }
        emit Burn(msg.sender, _from, _transactions);
    }

    function approve(address _spender, Transaction[] calldata _transactions)
    external
    virtual
    override
    {
        for (uint256 i = 0; i < _transactions.length; i++) {
            _classes[_transactions[i].classId]
            ._nonces[_transactions[i].nonceId]
            ._allowances[msg.sender][_spender] = _transactions[i].amount;
        }
    }

    function setApprovalFor(
        address operator,
        bool approved
    ) public virtual override {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalFor(msg.sender, operator, approved);
    }

    // READABLES
    function totalSupply(uint256 classId, uint256 nonceId)
    public
    view
    override
    returns (uint256)
    {
        return (activeSupply(classId, nonceId) +
        burnedSupply(classId, nonceId) +
        redeemedSupply(classId, nonceId)
        );
    }

    function activeSupply(uint256 classId, uint256 nonceId)
    public
    view
    override
    returns (uint256)
    {
        return _classes[classId]._nonces[nonceId]._activeSupply;
    }

    function burnedSupply(uint256 classId, uint256 nonceId)
    public
    view
    override
    returns (uint256)
    {
        return _classes[classId]._nonces[nonceId]._burnedSupply;
    }

    function redeemedSupply(uint256 classId, uint256 nonceId)
    public
    view
    override
    returns (uint256)
    {
        return _classes[classId]._nonces[nonceId]._redeemedSupply;
    }

    function balanceOf(
        address account,
        uint256 classId,
        uint256 nonceId
    ) public view override returns (uint256) {
        require(
            account != address(0),
            "ERC3475: balance query for the zero address"
        );
        return _classes[classId]._nonces[nonceId]._balances[account];
    }

    function classMetadata(uint256 metadataId)
    external
    view
    override
    returns (Metadata memory) {
        return (_classMetadata[metadataId]);
    }

    function nonceMetadata(uint256 classId, uint256 metadataId)
    external
    view
    override
    returns (Metadata memory) {
        return (_classes[classId]._nonceMetadatas[metadataId]);
    }

    function classValues(uint256 classId, uint256 metadataId)
    external
    view
    override
    returns (Values memory) {
        return (_classes[classId]._values[metadataId]);
    }


    function nonceValues(uint256 classId, uint256 nonceId, uint256 metadataId)
    external
    view
    override
    returns (Values memory) {
        return (_classes[classId]._nonces[nonceId]._values[metadataId]);
    }

    /** determines the progress till the  redemption of the bonds is valid  (based on the type of bonds class).
     * @notice ProgressAchieved and `progressRemaining` is abstract.
      For e.g. we are giving time passed and time remaining.
     */
    function getProgress(uint256 classId, uint256 nonceId)
    public
    view
    override
    returns (uint256 progressAchieved, uint256 progressRemaining){
        uint256 issuanceDate = _classes[classId]._nonces[nonceId]._values[0].uintValue;
        uint256 maturityDate = issuanceDate + _classes[classId]._nonces[nonceId]._values[5].uintValue;

        // check whether the bond is being already initialized:
        progressAchieved = block.timestamp - issuanceDate;
        progressRemaining = block.timestamp < maturityDate
        ? maturityDate - block.timestamp
        : 0;
    }
    /**
    gets the allowance of the bonds identified by (classId,nonceId) held by _owner to be spend by spender.
     */
    function allowance(
        address _owner,
        address spender,
        uint256 classId,
        uint256 nonceId
    ) public view virtual override returns (uint256) {
        return _classes[classId]._nonces[nonceId]._allowances[_owner][spender];
    }

    /**
    checks the status of approval to transfer the ownership of bonds by _owner  to operator.
     */
    function isApprovedFor(
        address _owner,
        address operator
    ) public view virtual override returns (bool) {
        return _operatorApprovals[_owner][operator];
    }

    // INTERNALS
    function _transferFrom(
        address _from,
        address _to,
        IERC3475.Transaction calldata _transaction
    ) private {
        Nonce storage nonce = _classes[_transaction.classId]._nonces[_transaction.nonceId];
        require(
            nonce._balances[_from] >= _transaction.amount,
            "ERC3475: not enough bond to transfer"
        );

        //transfer balance
        nonce._balances[_from] -= _transaction.amount;
        nonce._balances[_to] += _transaction.amount;
    }

    function _transferAllowanceFrom(
        address _operator,
        address _from,
        address _to,
        IERC3475.Transaction calldata _transaction
    ) private {
        Nonce storage nonce = _classes[_transaction.classId]._nonces[_transaction.nonceId];
        require(
            nonce._balances[_from] >= _transaction.amount,
            "ERC3475: not allowed amount"
        );
        // reducing the allowance and decreasing accordingly.
        nonce._allowances[_from][_operator] -= _transaction.amount;

        //transfer balance
        nonce._balances[_from] -= _transaction.amount;
        nonce._balances[_to] += _transaction.amount;
    }

    function _issue(
        address _to,
        IERC3475.Transaction calldata _transaction
    ) private {
        Nonce storage nonce = _classes[_transaction.classId]._nonces[_transaction.nonceId];

        //transfer balance
        nonce._balances[_to] += _transaction.amount;
        nonce._activeSupply += _transaction.amount;
    }


    function _redeem(
        address _from,
        IERC3475.Transaction calldata _transaction
    ) private {
        Nonce storage nonce = _classes[_transaction.classId]._nonces[_transaction.nonceId];
        // verify whether _amount of bonds to be redeemed  are sufficient available  for the given nonce of the bonds

        require(
            nonce._balances[_from] >= _transaction.amount,
            "ERC3475: not enough bond to transfer"
        );

        //transfer balance
        nonce._balances[_from] -= _transaction.amount;
        nonce._activeSupply -= _transaction.amount;
        nonce._redeemedSupply += _transaction.amount;
    }


    function _burn(
        address _from,
        IERC3475.Transaction calldata _transaction
    ) private {
        Nonce storage nonce = _classes[_transaction.classId]._nonces[_transaction.nonceId];
        // verify whether _amount of bonds to be burned are sfficient available for the given nonce of the bonds
        require(
            nonce._balances[_from] >= _transaction.amount,
            "ERC3475: not enough bond to transfer"
        );

        //transfer balance
        nonce._balances[_from] -= _transaction.amount;
        nonce._activeSupply -= _transaction.amount;
        nonce._burnedSupply += _transaction.amount;
    }

}

// File: secure_floor/contracts/SecureFloor.sol



pragma solidity ^0.8.0;




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

}



contract SecureFloor is ERC3475, Ownable {

    using TransferHelper for address;



    address public dumperShieldFactory;

    address public pdoFactory;



    struct FeeParams {

        uint8 feeType;  // 0 - free, 1 - 5% to DumperShield, 2 - 10% into PDO

        // DumperShield params

        address router; // dex router where exist pool "token-WETH" (token to native coin)

        uint64 dsReleaseTime;   // Epoch time (in seconds) when tokens will be unlocked in dumper shield. 0 if no DS needed

        // PDO params

        uint64 stakingPeriod; // number of days (0 means no staking)

        uint64 stakingAPY; // the percentage of APY with 4 decimals

    }



    struct Parameters {

        // step 1

        address token;  //  project token

        address pairToken;  // token that should be paid by users to add pool liquidity. Address(1) if native coin (BNB)

        address dexRouter;  // address of DEX router where is pool "token-pairToken". If 0, then create new pool with secure floor

        uint64  endDate;    // Epoch time (in seconds) when IBO will be closed.

        bool leftoverBurn;  // if true - burn leftover, false - return to project

        // step 2

        // vesting principal

        uint64 cliffData;   // epoch timestamp of cliff date (in seconds), if there isn't cliff then 0

        uint32 gradedPeriod; // period in seconds. If graded vesting, then release every 'period'

        uint32 gradedPortionPercent;    // percent to release every period

        // vesting profits

        uint64 cliffProfitData;   // epoch timestamp of cliff date (in seconds), if there isn't cliff then 0

        uint32 gradedProfitPeriod; // period in seconds. If graded vesting, then release every 'period'

        uint32 gradedProfitPortionPercent;    // percent to release every period

        uint32 prepaymentPenalty;   // percentage of initial penalty. During the time penalty will decrease

        // step 3

        uint256 supplyAmount;  // amount of tokens that project supply

        uint256 targetAmount;  // amount of pairTokens, used to calculate ratio for addLiquidity (supplyAmount:targetAmount)

        FeeParams feeParams;

        // limits

        uint256 minInvestment; // min investment in "pairToken"

        uint256 maxInvestment; // max investment in "pairToken"

    }





    event CreateBond(address creator, address licensee, Parameters p);

    event BuyBond(address buyer, uint256 classId, uint256 nonceId, uint256 bondAmounts);

    event Vote(address voter, uint256 classId, uint256 nonceId, uint256 ballotId, bool yea, uint256 votingPower);

    event CreateBallot(address voter, uint256 classId, uint256 nonceId, uint256 ruleId, bytes args, uint256 votingPower);





    function initialize() external {

        require(_owner == address(0));

        _owner = msg.sender;

        emit OwnershipTransferred(address(0), msg.sender);

        //super.initialize();

    }



    function createBond(address licensee, Parameters calldata p) external payable {

        if (p.dexRouter == address(0)) {

            p.token.safeTransferFrom(msg.sender, address(this), p.targetAmount);

            if (p.pairToken == address(1)) {

                uint256 price = p.targetAmount * 1e18 / p.supplyAmount;  // TODO: check decimals

                require(msg.value == price, "Not enough coin");

            } else {

                uint256 price = p.targetAmount * 1e18 / p.supplyAmount;  // TODO: check decimals

                p.pairToken.safeTransferFrom(msg.sender, address(this), price);

            }

        }

        emit CreateBond(msg.sender, licensee, p);

    }

    

    function buyBond(uint256 classId, uint256 nonceId, uint256 payAmount) external {

        uint256 bondAmounts = payAmount * 10;



        emit BuyBond(msg.sender, classId, nonceId, bondAmounts);

    }



    function vote(uint256 classId, uint256 nonceId, uint256 ballotId, bool yea) external {

        uint256 votingPower = 10;

        emit Vote(msg.sender, classId, nonceId, ballotId, yea, votingPower);

    }



    function createBallot(uint256 classId, uint256 nonceId, uint256 ruleId, bytes calldata args) external {

        uint256 votingPower = 10;

        emit CreateBallot(msg.sender, classId, nonceId, ruleId, args, votingPower);

    }



}