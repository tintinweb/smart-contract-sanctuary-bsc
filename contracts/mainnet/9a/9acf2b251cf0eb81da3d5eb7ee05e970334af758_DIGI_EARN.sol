/**
 *Submitted for verification at BscScan.com on 2022-10-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface TokenRecipient {
    function receiveApproval(
        address _from,
        uint256 _value,
        address _token,
        bytes calldata _extraData
    ) external;

    function tokenFallback(
        address from,
        uint256 value,
        bytes calldata data
    ) external;
}

/**
 * @dev Interface of the BEP20 token.
 */
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @title Ownership
 * @author Prashant Prabhakar Singh
 * @dev Contract that allows to hande ownership of contract
 */
contract Ownership {
    address public owner;
    event LogOwnershipTransferred(
        address indexed oldOwner,
        address indexed newOwner
    );

    constructor() {
        owner = msg.sender;
        emit LogOwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner is allowed");
        _;
    }

    /**
     * @dev Transfers ownership of contract to other address
     * @param _newOwner address The address of new owner
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Zero address not allowed");
        address oldOwner = owner;
        owner = _newOwner;
        emit LogOwnershipTransferred(oldOwner, _newOwner);
    }

    /**
     * @dev Removes owner from the contract.
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     * @param _code uint that prevents accidental calling of the function
     */
    function renounceOwnership(uint256 _code) public onlyOwner {
        require(_code == 1234567890, "Invalid code");
        owner = address(0);
        emit LogOwnershipTransferred(owner, address(0));
    }
}

/**
 * @title Freezable
 * @author Prashant Prabhakar Singh
 * @dev Contract that allows freezing/unfreezing an address or complete contract
 */
contract Freezable is Ownership {
    bool public emergencyFreeze;
    mapping(address => bool) public frozen;

    event LogFreezed(address indexed target, bool freezeStatus);
    event LogEmergencyFreezed(bool emergencyFreezeStatus);

    modifier unfreezed(address _account) {
        require(!frozen[_account], "Account is freezed");
        _;
    }

    modifier noEmergencyFreeze() {
        require(!emergencyFreeze, "Contract is emergency freezed");
        _;
    }

    /**
     * @dev Freezes or unfreezes an addreess
     * this does not check for previous state before applying new state
     * @param _target the address which will be feeezed.
     * @param _freeze boolean status. Use true to freeze and false to unfreeze.
     */
    function freezeAccount(address _target, bool _freeze) public onlyOwner {
        require(_target != address(0), "Zero address not allowed");
        frozen[_target] = _freeze;
        emit LogFreezed(_target, _freeze);
    }

    /**
     * @dev Freezes or unfreezes the contract
     * this does not check for previous state before applying new state
     * @param _freeze boolean status. Use true to freeze and false to unfreeze.
     */
    function emergencyFreezeAllAccounts(bool _freeze) public onlyOwner {
        emergencyFreeze = _freeze;
        emit LogEmergencyFreezed(_freeze);
    }
}

/**
 * @title StandardToken
 * @author Prashant Prabhakar Singh
 * @dev A Standard Token contract that follows BEP-20 standard
 */
contract StandardToken is IBEP20, Freezable {
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public currentCirculation;
    uint256 internal _totalSupply;
    uint256 internal initialTotalSupply;

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;
    mapping(address => bool) public trustedContracts;

    event TrustedContractUpdate(address _contractAddress, bool _added);

    constructor() {
        name = "DIGI EARN";
        symbol = "DGERN";
        decimals = 4;
        initialTotalSupply = 500000000 * (10 ** decimals);
        _totalSupply = initialTotalSupply;
        mint(owner, 10000000 * (10 ** decimals));
    }

    /**
     * @dev Modifier to revert for zero address
     */
    modifier onlyNonZeroAddress(address account) {
        require(account != address(0), "Zero address not allowed");
        _;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _value The amount of tokens to mint.
     */
    function mint(address _to, uint256 _value) public onlyOwner {
        balances[_to] = balances[_to] + _value;
        currentCirculation += _value;
        if(currentCirculation > initialTotalSupply) {
          _totalSupply = currentCirculation;
        }
        emit Transfer(address(0), _to, _value);
    }

    /**
     * @dev See {IBEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     * - the caller must not be freezed.
     * - the recipient must not be freezed.
     * - contract must not be freezed.
     */
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        return _transfer(msg.sender, recipient, amount);
    }

    /**
     * @dev See {IBEP20-transferFrom}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least `amount`.
     * - the caller must not be freezed.
     * - the recipient must not be freezed.
     * - contract must not be freezed.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        require(
            amount <= allowed[sender][msg.sender],
            "Insufficient allowance"
        );
        allowed[sender][msg.sender] = allowed[sender][msg.sender] - amount;
        return _transfer(sender, recipient, amount);
    }

    /**
     * @dev See {IBEP20-transfer}.
     * Bulk action for transfer tokens
     * Requirements:
     *
     * - number of `recipients` and number of `amounts` must match
     * - the caller must have a balance of at least sum of `amounts`.
     * - the caller must not be freezed.
     * - the recipients must not be freezed.
     * - contract must not be freezed.
     */
    function bulkTransfer(address[] memory recipients, uint256[] memory amounts)
        public
        returns (bool)
    {
        require(recipients.length == amounts.length, "Invalid length");
        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amounts[i]);
        }
        return true;
    }

    function bulkTransferFrom(
        address sender,
        address[] memory recipients,
        uint256[] memory amounts
    ) public returns (bool) {
        require(recipients.length == amounts.length, "Invalid length");
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            totalAmount += amounts[i];
            _transfer(sender, recipients[i], amounts[i]);
        }
        require(
            totalAmount <= allowed[sender][msg.sender],
            "Insufficient allowance"
        );
        allowed[sender][msg.sender] = allowed[sender][msg.sender] - totalAmount;
        return true;
    }

    /**
     * @dev See {IBEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        return _approve(msg.sender, spender, amount);
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - contract must not be freezed.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        return
            _approve(
                msg.sender,
                spender,
                allowed[msg.sender][spender] + addedValue
            );
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least `subtractedValue`.
     * - contract must not be freezed.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        uint256 _value = allowed[msg.sender][spender] - subtractedValue;
        if (subtractedValue > _value) {
            _value = 0;
        }
        return _approve(msg.sender, spender, _value);
    }

    /**
     * @dev Utility method to check if an address is contract address
     *
     * @param _addr address which is being checked.
     * @return true if address belongs to a contract else returns false
     */
    function isContract(address _addr) private view returns (bool) {
        uint256 length;
        assembly {
            length := extcodesize(_addr)
        }
        return (length > 0);
    }

    function addTrustedContracts(address _contractAddress, bool _isActive)
        public
        onlyOwner
    {
        require(
            isContract(_contractAddress),
            "Only contract address can be added"
        );
        trustedContracts[_contractAddress] = _isActive;
        emit TrustedContractUpdate(_contractAddress, _isActive);
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     * Calls `tokenFallback` function if recipeitn is a trusted contract address
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least `amount`.
     * - the caller must not be freezed.
     * - the recipient must not be freezed.
     * - contract must not be freezed.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    )
        internal
        unfreezed(recipient)
        unfreezed(sender)
        noEmergencyFreeze
        onlyNonZeroAddress(recipient)
        returns (bool)
    {
        require(balances[sender] >= amount, "Insufficient funds");
        balances[sender] = balances[sender] - amount;
        balances[recipient] = balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        notifyTrustedContract(sender, recipient, amount);
        return true;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `owner` can not be freezed
     * - `spender` can not be freezed
     * - contract can not be freezed
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal noEmergencyFreeze onlyNonZeroAddress(spender) returns (bool) {
        allowed[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        return true;
    }

    /**
     * @dev Notifier trusted contracts when tokens are transferred to them
     *
     * Requirements:
     *
     * - `recipient` must be a trusted contract.
     * - `recipient` must implement `tokenFallback` function
     */
    function notifyTrustedContract(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        // if the contract is trusted, notify it about the transfer
        if (trustedContracts[recipient]) {
            TokenRecipient trustedContract = TokenRecipient(recipient);
            bytes memory data;
            trustedContract.tokenFallback(sender, amount, data);
        }
    }

    /**
     * @dev Owner can transfer any BEP20 compitable tokens send to this contract
     *
     */
    function transferAnyBEP20Token(address _tokenAddress, uint256 _value)
        public
        onlyOwner
        returns (bool)
    {
        return IBEP20(_tokenAddress).transfer(owner, _value);
    }

    /**
     * @dev Function that burns an amount of the token of a sender.
     * reduces total supply.
     * only owner is allowed to burn tokens.
     *
     * @param _value The amount that will be burn.
     */
    function burn(uint256 _value)
        public
        noEmergencyFreeze
        onlyOwner
        returns (bool success)
    {
        require(balances[msg.sender] >= _value, "Insufficient balance");
        balances[msg.sender] = balances[msg.sender] - _value;
        _totalSupply -= _value;
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param _tokenOwner The address to query the balance of.
     * @return A uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _tokenOwner)
        public
        view
        override
        returns (uint256)
    {
        return balances[_tokenOwner];
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _tokenOwner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _tokenOwner, address _spender)
        public
        view
        override
        returns (uint256)
    {
        return allowed[_tokenOwner][_spender];
    }
}

contract DIGI_EARN is StandardToken {
    mapping(address => mapping(uint256 => bool)) public isNonceUsed;

    struct Signature {
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * @param from address The address from which you want to send tokens.
     * @param to address The address to which you want to transfer tokens.
     * @param value uint256 the amount of tokens to be transferred.
     * @param sig Signature of {from}
     * @param txNonce uint256 nonce to prevent tx replay
     */
    function signedTransfer(
        address from,
        address to,
        uint256 value,
        Signature calldata sig,
        uint256 txNonce
    ) public returns (bool success) {
        bytes32 signedMessage = keccak256(
            abi.encodePacked(
                getChainID(),
                address(this),
                bytes4(keccak256("signedTransfer")),
                txNonce,
                from,
                to,
                value
            )
        );
        address signer = getSigner(signedMessage, sig);
        require(!isNonceUsed[signer][txNonce], "Tx nonce already used");
        isNonceUsed[signer][txNonce] = true;
        return _transfer(signer, to, value);
    }

    /**
     * @dev increases current allowance
     * @param _spender address who is allowed to spend
     * @param _addedValue the no of tokens added to previous allowance
     * @param sig Signature of the user from which approval happens
     * @param txNonce nonce to prevent tx replay
     * @return success if everything goes well
     */
    function signedIncreaseAllowance(
        address _spender,
        uint256 _addedValue,
        Signature calldata sig,
        uint256 txNonce
    ) public returns (bool) {
        bytes32 signedMessage = keccak256(
            abi.encodePacked(
                getChainID(),
                address(this),
                bytes4(keccak256("signedIncreaseAllowance")),
                txNonce,
                _spender,
                _addedValue
            )
        );
        address signer = getSigner(signedMessage, sig);
        require(!isNonceUsed[signer][txNonce], "Tx nonce already used");
        isNonceUsed[signer][txNonce] = true;
        return
            _approve(signer, _spender, allowed[signer][_spender] + _addedValue);
    }

    /**
     * @dev signedDecreaseApproval: decrease current allowance.
     * @param _spender address who is allowed to spend.
     * @param _subtractedValue the no of tokens deducted to previous allowance
     * If _subtractedValue is greater than prev allowance, allowance becomes 0
     * @param sig Signature of the user from which approval happens.
     * @param txNonce uint256 nonce to prevent tx replay.
     * @return success if everything goes well.
     */
    function signedDecreaseApproval(
        address _spender,
        uint256 _subtractedValue,
        Signature calldata sig,
        uint256 txNonce
    ) public returns (bool) {
        bytes32 signedMessage = keccak256(
            abi.encodePacked(
                getChainID(),
                address(this),
                bytes4(keccak256("signedDecreaseApproval")),
                txNonce,
                _spender,
                _subtractedValue
            )
        );
        address signer = getSigner(signedMessage, sig);
        require(!isNonceUsed[signer][txNonce], "Tx nonce already used");
        isNonceUsed[signer][txNonce] = true;

        uint256 _value = allowed[signer][_spender] - _subtractedValue;
        if (_subtractedValue > _value) {
            _value = 0;
        }
        return _approve(signer, _spender, _value);
    }

    function getSigner(bytes32 signedMessage, Signature calldata sig)
        private
        pure
        returns (address)
    {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        return
            ecrecover(
                keccak256(abi.encodePacked(prefix, signedMessage)),
                sig.v,
                sig.r,
                sig.s
            );
    }

    function getChainID() public view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }
}