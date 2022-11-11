/**
 *Submitted for verification at BscScan.com on 2022-11-10
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
    function getLimit(uint256 classId, uint256 nonceId) external view returns(int256);

    event CreateBond(uint256 classId, uint256 nonceId, address token, BondParameters parameters);
}

// File: Bond/contracts/ERC3475.sol



pragma solidity ^0.8.0;


interface IPair {
    function symbol() external pure returns (string memory);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function balanceOf(address owner) external view returns (uint);
    function totalSupply() external view returns (uint);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function burn(address to) external returns (uint amount0, uint amount1);

    function vote(uint256 _ballotId, bool yea, uint256 voteLP) external returns (bool);
    function createBallot(uint256 ruleId, bytes calldata args, uint256 voteLP) external;
    function votingTime() external view returns (uint);
}

interface IWETH {
    function withdraw(uint) external;
}

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

contract ERC3475 is IERC3475 {
    using TransferHelper for address;

    /**
     * @notice this Struct is representing the Nonce properties as an object
     */
    struct Nonce {
        mapping(uint256 => IERC3475.Values) _values;

        // stores the values corresponding to the dates (issuance and maturity date).
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
        mapping(address => uint256) _voteLock;  // voter lock time 

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

    // IBO setting
    address public derexToken;  // Derex token that pays as reward by Derex DEX
    address public WETH; 
    address public bank;    // contract that can create, issue and redeem bonds

    event Vote(address voter, uint256 classId, uint256 nonceId, uint256 ballotId, bool yea, uint256 votingPower);
    event CreateBallot(address voter, uint256 classId, uint256 nonceId, uint256 ruleId, bytes args, uint256 votingPower);

    /**
     * @notice Here the constructor is just to initialize a class and nonce,
     * in practice, you will have a function to create a new class and nonce
     * to be deployed during the initial deployment cycle
     */
    constructor(address _derexToken, address _WETH, address _bank) {
//    function initialize() public virtual {

        require(_WETH != address(0) && _bank != address(0));
        derexToken = _derexToken;
        WETH = _WETH;
        bank = _bank;

        // define "symbol of the class";
        _classMetadata[0].title = "symbol";
        _classMetadata[0]._type = "string";
        _classMetadata[0].description = "symbol of the class";
        // total number of nonces (subclasses) in the class
        _classMetadata[1].title = "nonceNumbers";
        _classMetadata[1]._type = "int";
        _classMetadata[1].description = "numbers of nonces";
        //  project token
        _classMetadata[2].title = "token";
        _classMetadata[2]._type = "address";
        _classMetadata[2].description = "project token address";

        // define metadata on nonce
        // Pair token to project token in the liquidity pool (LP).
        _classes[0]._nonceMetadatas[0].title = "pairToken";
        _classes[0]._nonceMetadatas[0]._type = "address";
        _classes[0]._nonceMetadatas[0].description = "pair token in LP";
        // address of DEX router where is pool "token-pairToken". If 0, then create new pool with secure floor
        _classes[0]._nonceMetadatas[1].title = "LPToken";
        _classes[0]._nonceMetadatas[1]._type = "address";
        _classes[0]._nonceMetadatas[1].description = "LP pair address";
        // Wallet that receive project tokens after bond redemption. Burn if address is 0
        _classes[0]._nonceMetadatas[2].title = "projectWallet"; 
        _classes[0]._nonceMetadatas[2]._type = "address";
        _classes[0]._nonceMetadatas[2].description = "project token receiver";
        // Date when bond issued (epoch timestamp)
        _classes[0]._nonceMetadatas[3].title = "issuanceDate";
        _classes[0]._nonceMetadatas[3]._type = "int";
        _classes[0]._nonceMetadatas[3].description = "bond issuance date";
        // percentage with 4 decimals of initial penalty. During the time penalty will decrease. If 0 then withdrawing before release not allowed 
        // penalty = prepaymentPenalty * days to vesting / initial vesting period
        _classes[0]._nonceMetadatas[4].title = "prepaymentPenalty";
        _classes[0]._nonceMetadatas[4]._type = "int";
        _classes[0]._nonceMetadatas[4].description = "dynamic penalty percent";
        // vesting principal
        // epoch timestamp of cliff date (in seconds)
        _classes[0]._nonceMetadatas[5].title = "maturityDate";
        _classes[0]._nonceMetadatas[5]._type = "int";
        _classes[0]._nonceMetadatas[5].description = "cliff date";
        // vesting profits
        // epoch timestamp of cliff date (in seconds)
        _classes[0]._nonceMetadatas[6].title = "maturityProfitDate";
        _classes[0]._nonceMetadatas[6]._type = "int";
        _classes[0]._nonceMetadatas[6].description = "cliff profit date";

        // invested principle amount of pairToken require to receive to start profit vesting
        _classes[0]._nonceMetadatas[7].title = "principleAmount";
        _classes[0]._nonceMetadatas[7]._type = "int";
        _classes[0]._nonceMetadatas[7].description = "principle amount";
    }

    /**
     * @dev Throws if called by any account other than the bank contract.
     */
    modifier onlyBank() {
        require(msg.sender == bank, "onlyBank");
        _;
    }

    // this bond specific functions
    function createBond(
        address token,  // project token is used as classId
        BondParameters calldata p // parameters of bond
    ) 
    onlyBank 
    external 
    virtual 
    override 
    returns (uint256 classId, uint256 nonceId) 
    {
        classId = uint256(uint160(token));
        nonceId = _classes[classId]._values[1].uintValue;
        _classes[classId]._values[1].uintValue = nonceId + 1;   // number of nonce
        if (nonceId == 0) { // first nonce
            // class settings
            _classes[classId]._values[0].stringValue = IPair(token).symbol();   // bond symbol
            _classes[classId]._values[2].addressValue = token;  // project token
        }

        Nonce storage nonce = _classes[classId]._nonces[nonceId];
        // nonce settings
        IPair pair = IPair(p.LPToken);
        address token0 = pair.token0();
        address token1 = pair.token1();
        // set pairToken
        if (token == token0) nonce._values[0].addressValue = token1;
        else if (token == token1) nonce._values[0].addressValue = token0;
        else revert("Incorrect LP");
        nonce._values[1].addressValue = p.LPToken;
        nonce._values[2].addressValue = p.projectWallet;

        // vesting settings
        nonce._values[3].uintValue = p.issuanceDate;
        nonce._values[4].uintValue = p.prepaymentPenalty;
        nonce._values[5].uintValue = p.maturityDate;
        nonce._values[6].uintValue = p.maturityProfitDate;
        
        emit CreateBond(classId, nonceId, token, p);
    }
    
    // vote on Derex pool
    function vote(uint256 classId, uint256 nonceId, uint256 ballotId, bool yea) external {
        Nonce storage nonce = _classes[classId]._nonces[nonceId];
        IPair lp = IPair(nonce._values[1].addressValue);
        uint256 votingPower = nonce._balances[msg.sender];
        lp.vote(ballotId, yea, votingPower);
        // lock transfer
        _classes[classId]._nonces[nonceId]._voteLock[msg.sender] = block.timestamp + lp.votingTime();
        emit Vote(msg.sender, classId, nonceId, ballotId, yea, votingPower);
    }

    // create proposal on Derex pool
    function createBallot(uint256 classId, uint256 nonceId, uint256 ruleId, bytes calldata args) external {
        Nonce storage nonce = _classes[classId]._nonces[nonceId];
        IPair lp = IPair(nonce._values[1].addressValue);
        uint256 votingPower = nonce._balances[msg.sender];
        lp.createBallot(ruleId, args, votingPower);
        // lock transfer
        _classes[classId]._nonces[nonceId]._voteLock[msg.sender] = block.timestamp + lp.votingTime();
        emit CreateBallot(msg.sender, classId, nonceId, ruleId, args, votingPower);
    }

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
    onlyBank
    external
    virtual
    override
    {
        uint256 len = _transactions.length;
        for (uint256 i = 0; i < len; i++) {
            require(
                _to != address(0),
                "ERC3475: can't issue to the zero address"
            );
            _issue(_to, _transactions[i]);
        }
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
        // alow owner or approved address to redeem
        require(
            msg.sender == _from ||
            isApprovedFor(_from, msg.sender) ||
            msg.sender == bank,
            "ERC3475: caller-not-owner-or-approved"
        );

        uint256 len = _transactions.length;
        for (uint256 i = 0; i < len; i++) {
            //(, uint256 progressRemaining) = getProgress(
            int256 limit = getLimit(
                _transactions[i].classId,
                _transactions[i].nonceId
            );
            require(
                //progressRemaining == 0,
                limit >= 0,
                "ERC3475 Error: Not redeemable"
            );
            _redeem(uint256(limit), _from, _transactions[i]);
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
        classId = 0;   // all classes have the same nonceMetadata
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
     */
    function getProgress(uint256 classId, uint256 nonceId)
    public
    view
    override
    returns (uint256 progressAchieved, uint256 progressRemaining){
        Nonce storage nonce = _classes[classId]._nonces[nonceId];
        uint256 issuanceDate = nonce._values[3].uintValue;
        uint256 maturityDate;
        if (nonce._values[7].uintValue != 0) { // principeAmount not received yet
            // maturity for principle
            maturityDate = nonce._values[5].uintValue;
        } else {
            // maturity for profit
            maturityDate = nonce._values[6].uintValue;
        }

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

    // return maximum amount of pairToken is allowed to redeem. (0) means "no limit", (-1) means "nothing allowed"
    function getLimit(uint256 classId, uint256 nonceId) public view virtual override returns(int256) {
        Nonce storage nonce = _classes[classId]._nonces[nonceId];
        if(nonce._values[5].uintValue > block.timestamp) return -1; // maturityDate is not reached - nothing allowed
        else if (nonce._values[6].uintValue <= block.timestamp) return 0; // maturityProfitDate reached - no limit
        else return int256(nonce._values[7].uintValue); // principleAmount allowed
    }

    // return vote lock time
    function getVoteLock(uint256 classId, uint256 nonceId, address user) public view returns(uint256) {
        return _classes[classId]._nonces[nonceId]._voteLock[user];
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

        require(nonce._voteLock[_from] < block.timestamp, "Bond is locked");    // voting lock
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
        require(nonce._voteLock[_from] < block.timestamp, "Bond is locked");    // voting lock

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
        address projectToken = _classes[_transaction.classId]._values[2].addressValue;
        address pairToken = nonce._values[0].addressValue;
        address lp = nonce._values[1].addressValue;
        // issue amount of bond equal to lp amount
        lp.safeTransferFrom(msg.sender, address(this), _transaction.amount);
        // get principleAmount
        (uint112 reserve0, uint112 reserve1,) = IPair(lp).getReserves();
        if (projectToken > pairToken) (reserve0, reserve1) = (reserve1, reserve0); // reserve1 is amount of pairToken
        uint256 totalLP = IPair(lp).totalSupply();
        uint256 principleAmount = uint256(reserve1) * _transaction.amount / totalLP;
        nonce._values[7].uintValue += principleAmount;

        //transfer balance
        nonce._balances[_to] += _transaction.amount;
        nonce._activeSupply += _transaction.amount;
    }


    function _redeem(
        uint256 limit,
        address _from,
        IERC3475.Transaction calldata _transaction
    ) private {
        Nonce storage nonce = _classes[_transaction.classId]._nonces[_transaction.nonceId];
        // verify whether _amount of bonds to be redeemed  are sufficient available  for the given nonce of the bonds

        require(
            nonce._balances[_from] >= _transaction.amount,
            "ERC3475: not enough bond to transfer"
        );

        require(nonce._voteLock[_from] < block.timestamp, "Bond is locked");    // voting lock
        
        //transfer balance
        nonce._balances[_from] -= _transaction.amount;
        nonce._activeSupply -= _transaction.amount;
        nonce._redeemedSupply += _transaction.amount;


        // remove Liquidity
        address projectToken = _classes[_transaction.classId]._values[2].addressValue;
        address pairToken = nonce._values[0].addressValue;
        address lp = nonce._values[1].addressValue;
        lp.safeTransferFrom(address(this), lp, _transaction.amount);
        IPair(lp).burn(address(this));
        // check real amount of receiving tokens to support tokens with fee on transfer
        uint256 projectTokenAmount = IPair(projectToken).balanceOf(address(this));
        uint256 pairTokenAmount = IPair(pairToken).balanceOf(address(this));
        if (pairToken == WETH) {
            // pairToken is native coin
            IWETH(WETH).withdraw(pairTokenAmount);
            _from.safeTransferETH(pairTokenAmount);
        } else {
            pairToken.safeTransfer(_from, pairTokenAmount);
        }

        if (limit > 0) {
            require(limit >= pairTokenAmount, "amount > principle");
            nonce._values[7].uintValue -= pairTokenAmount; // reduce principle amount
        } else {
            nonce._values[7].uintValue = 0; // can be redeemed any value
        }

        // transfer Derex token if exist
        if (derexToken != address(0) && derexToken != projectToken && derexToken != pairToken) {
            uint256 derexAmount = IPair(derexToken).balanceOf(address(this));
            if (derexAmount != 0) derexToken.safeTransfer(_from, derexAmount);
        }

        // transfer project tokens to project wallet
        address projectWallet = nonce._values[2].addressValue;
        projectToken.safeTransfer(projectWallet, projectTokenAmount);
    }


    function _burn(
        address _from,
        IERC3475.Transaction calldata _transaction
    ) private {
        Nonce storage nonce = _classes[_transaction.classId]._nonces[_transaction.nonceId];
        // verify whether _amount of bonds to be burned are sufficient available for the given nonce of the bonds
        require(
            nonce._balances[_from] >= _transaction.amount,
            "ERC3475: not enough bond to transfer"
        );

        //transfer balance
        nonce._balances[_from] -= _transaction.amount;
        nonce._activeSupply -= _transaction.amount;
        nonce._burnedSupply += _transaction.amount;
    }

    receive() external payable {
        require(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }
}