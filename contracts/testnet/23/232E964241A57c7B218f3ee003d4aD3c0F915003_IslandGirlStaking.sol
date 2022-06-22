// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

contract IslandGirlStaking is Ownable {
    using Address for address;

    IBEP20 public  acceptedToken;

    uint8 private _decimals = 9;

    uint256 public flexibleBasisPoints;
    uint256 public oneMonthBasisPoints;
    uint256 public threeMonthsBasisPoints;
    uint256 public sixMonthsBasisPoints;
    uint256 public twelveMonthsBasisPoints;

    mapping(address => uint256) public depositStart;
    mapping(address => uint256) public IslandGirlBalanceOf;
    mapping(address => bool) public isDeposited;
    mapping(address => uint256) public depositOption;

    event DepositEvent(
        address indexed user,
        uint256 IGIRLAmount,
        uint256 timeStart
    );
    event WithdrawEvent(
        address indexed user,
        uint256 IGIRLAmount,
        uint256 interest
    );

    constructor(
        address _acceptedToken,
        uint256 _flexible,
        uint256 _30bps,
        uint256 _90bps,
        uint256 _180bps,
        uint256 _360bps
    ) {
        acceptedToken = IBEP20(_acceptedToken);
        flexibleBasisPoints = _flexible;
        oneMonthBasisPoints = _30bps;
        threeMonthsBasisPoints = _90bps;
        sixMonthsBasisPoints = _180bps;
        twelveMonthsBasisPoints = _360bps;
    }

    function deposit(uint256 _amount, uint256 _option) external {
        require(_amount >= 0, "Error, deposit must be >= 0");
        // require(isDeposited[msg.sender]==false, "Error, you have already deposited");

        IslandGirlBalanceOf[msg.sender] += _amount;
        depositStart[msg.sender] = block.timestamp;
        isDeposited[msg.sender] = true; 
        depositOption[msg.sender] = _option;

        acceptedToken.transfer(address(this), _amount);
    }

    function testtransfer(address to, uint256 amount) external {
        acceptedToken.transfer(to, amount);
    } 
    function withdraw() public {
        require(isDeposited[msg.sender] == true, "Error, no previous deposit");

        uint256 interest = calculateInterests(msg.sender);
        uint256 userBalance = IslandGirlBalanceOf[msg.sender];

        //reset depositer data
        IslandGirlBalanceOf[msg.sender] = 0;
        isDeposited[msg.sender] = false;
        //send funds to user
        // _mint(msg.sender, interest);
        acceptedToken.transfer(msg.sender, interest);
        acceptedToken.transfer(msg.sender, userBalance);

        emit WithdrawEvent(msg.sender, userBalance, interest);
    }

    function withdrawInterests() public {
        require(isDeposited[msg.sender] == true, "Error, no previous deposit");

        uint256 interest = calculateInterests(msg.sender);

        // reset depositStart

        depositStart[msg.sender] = block.timestamp;

        // mint interests
        acceptedToken.transfer(msg.sender, interest);
        //_mint(msg.sender, interest);
    }

    // calculates the interest for each second on timestamp

    function calculateInterests(address _user)
        public
        view
        returns (uint256 insterest)
    {
        // get balance and deposit time
        uint256 userBalance = IslandGirlBalanceOf[_user];
        uint256 depositTime = block.timestamp - depositStart[msg.sender];
        uint256 option = depositOption[msg.sender];

        // calculate the insterest per year

        uint256 basisPoints = getBasisPoints(option);
        uint256 interestPerMili = (userBalance * basisPoints) /
            (100 * 30 * 24 * 3600 * 1000);

        // get the interest on depositTime

        uint256 interests = interestPerMili * (depositTime);

        return interests;
    }

    function getBasisPoints(uint256 _option)
        public
        view
        returns (uint256 basisPoints)
    {
        if (_option == 0) {
            return flexibleBasisPoints;
        } else if (_option == 1) {
            return threeMonthsBasisPoints;
        } else if (_option == 2) {
            return sixMonthsBasisPoints;
        } else if (_option == 3) {
            return twelveMonthsBasisPoints;
        } else if (_option == 4) {
            return twelveMonthsBasisPoints;
        }
    }

    function changeInterestRate(
        uint256 _flexible,
        uint256 _30bps,
        uint256 _90bps,
        uint256 _180bps,
        uint256 _360bps
    ) public onlyOwner {
        flexibleBasisPoints = _flexible;
        oneMonthBasisPoints = _30bps;
        threeMonthsBasisPoints = _90bps;
        sixMonthsBasisPoints = _180bps;
        twelveMonthsBasisPoints = _360bps;
    }

    // function mint(address _recipient, uint256 _amount) public onlyOwner {
    //     _mint(_recipient, _amount);
    // }
}