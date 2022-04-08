/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            'Address: insufficient balance'
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(
            success,
            'Address: unable to send value, recipient may have reverted'
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, 'Address: low-level call failed');
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

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
                'Address: low-level call with value failed'
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            'Address: insufficient balance for call'
        );
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                'Address: low-level static call failed'
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), 'Address: static call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                'Address: low-level delegate call failed'
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), 'Address: delegate call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

    function addressToString(address _address)
        internal
        pure
        returns (string memory)
    {
        bytes32 _bytes = bytes32(uint256(_address));
        bytes memory HEX = '0123456789abcdef';
        bytes memory _addr = new bytes(42);

        _addr[0] = '0';
        _addr[1] = 'x';

        for (uint256 i = 0; i < 20; i++) {
            _addr[2 + i * 2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _addr[3 + i * 2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }

        return string(_addr);
    }
}

library Counters {
    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

interface IERC20Mintable is IERC20 {
    function mint(uint256 amount_) external;

    function mint(address account_, uint256 ammount_) external;
}

interface IERC20Burnable is IERC20 {
    function burn(address account_, uint256 ammount_) external;
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeERC20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeERC20: decreased allowance below zero'
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            'SafeERC20: low-level call failed'
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                'SafeERC20: ERC20 operation did not succeed'
            );
        }
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function sqrrt(uint256 a) internal pure returns (uint256 c) {
        if (a > 3) {
            c = a;
            uint256 b = add(div(a, 2), 1);
            while (b < c) {
                c = b;
                b = div(add(div(a, b), b), 2);
            }
        } else if (a != 0) {
            c = 1;
        }
    }
}

interface IFnyTreasury {
    function excessReserves() external view returns (uint256);

    function deposit(
        uint256 _amount,
        address _token,
        uint256 _profit
    ) external returns (uint256 sent_);

    function valueOfToken(address _token, uint256 _amount)
        external
        view
        returns (uint256 value_);

    function mintRewards(address _recipient, uint256 _amount) external;

    function manage(address _token, uint256 _amount) external;

    function withdraw(uint256 _amount, address _token) external;
}

interface IOwnable {
    function owner() external view returns (address);

    function renounceManagement() external;

    function pushManagement(address newOwner_) external;

    function pullManagement() external;
}

contract Ownable is IOwnable {
    address internal _owner;
    address internal _newOwner;

    event OwnershipPushed(
        address indexed previousOwner,
        address indexed newOwner
    );
    event OwnershipPulled(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
        emit OwnershipPushed(address(0), _owner);
    }

    function owner() public view override returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, 'Ownable: caller is not the owner');
        _;
    }

    function renounceManagement() public virtual override onlyOwner {
        emit OwnershipPushed(_owner, address(0));
        _owner = address(0);
    }

    function pushManagement(address newOwner_)
        public
        virtual
        override
        onlyOwner
    {
        require(
            newOwner_ != address(0),
            'Ownable: new owner is the zero address'
        );
        emit OwnershipPushed(_owner, newOwner_);
        _newOwner = newOwner_;
    }

    function pullManagement() public virtual override {
        require(msg.sender == _newOwner, 'Ownable: must be new owner to pull');
        emit OwnershipPulled(_owner, _newOwner);
        _owner = _newOwner;
    }
}

interface ICLAMERC20 {
    function burnFrom(address account_, uint256 amount_) external;
}

interface IBondCalculator {
    function valuation(address pair_, uint256 amount_)
        external
        view
        returns (uint256 _value);
}

contract FnyTreasury is Ownable, IFnyTreasury {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event Deposit(address indexed token, uint256 amount, uint256 value);
    event Withdrawal(address indexed token, uint256 amount, uint256 value);
    event CreateDebt(
        address indexed debtor,
        address indexed token,
        uint256 amount,
        uint256 value
    );
    event RepayDebt(
        address indexed debtor,
        address indexed token,
        uint256 amount,
        uint256 value
    );
    event ReservesManaged(address indexed token, uint256 amount);
    event ReservesUpdated(uint256 indexed totalReserves);
    event ReservesAudited(uint256 indexed totalReserves);
    event RewardsMinted(
        address indexed caller,
        address indexed recipient,
        uint256 amount
    );
    event ChangeQueued(MANAGING indexed managing, address queued);
    event ChangeActivated(
        MANAGING indexed managing,
        address activated,
        bool result
    );

    enum MANAGING {
        RESERVEDEPOSITOR,
        RESERVESPENDER,
        RESERVETOKEN,
        RESERVEMANAGER,
        LIQUIDITYDEPOSITOR,
        LIQUIDITYTOKEN,
        LIQUIDITYMANAGER,
        DEBTOR,
        REWARDMANAGER,
        SCLAM
    }

    address public immutable CLAM;
    uint256 public immutable blocksNeededForQueue;

    address[] public reserveTokens;
    mapping(address => bool) public isReserveToken;
    mapping(address => uint256) public reserveTokenQueue;

    address[] public reserveDepositors;
    mapping(address => bool) public isReserveDepositor;
    mapping(address => uint256) public reserveDepositorQueue;

    address[] public reserveSpenders;
    mapping(address => bool) public isReserveSpender;
    mapping(address => uint256) public reserveSpenderQueue;

    address[] public liquidityTokens;
    mapping(address => bool) public isLiquidityToken;
    mapping(address => uint256) public LiquidityTokenQueue;

    address[] public liquidityDepositors;
    mapping(address => bool) public isLiquidityDepositor;
    mapping(address => uint256) public LiquidityDepositorQueue;

    mapping(address => address) public bondCalculator;

    address[] public reserveManagers;
    mapping(address => bool) public isReserveManager;
    mapping(address => uint256) public ReserveManagerQueue;

    address[] public liquidityManagers;
    mapping(address => bool) public isLiquidityManager;
    mapping(address => uint256) public LiquidityManagerQueue;

    address[] public debtors;
    mapping(address => bool) public isDebtor;
    mapping(address => uint256) public debtorQueue;
    mapping(address => uint256) public debtorBalance;

    address[] public rewardManagers;
    mapping(address => bool) public isRewardManager;
    mapping(address => uint256) public rewardManagerQueue;

    address public sCLAM;
    uint256 public sCLAMQueue;

    uint256 public totalReserves;
    uint256 public totalDebt;

    constructor(
        address _CLAM,
        address _DAI,
        address _CLAMDAI,
        address _bondCalculator,
        uint256 _blocksNeededForQueue
    ) {
        require(_CLAM != address(0));
        CLAM = _CLAM;

        isReserveToken[_DAI] = true;
        reserveTokens.push(_DAI);

        isLiquidityToken[_CLAMDAI] = true;
        liquidityTokens.push(_CLAMDAI);
        bondCalculator[_CLAMDAI] = _bondCalculator;

        blocksNeededForQueue = _blocksNeededForQueue;
    }

    function deposit(
        uint256 _amount,
        address _token,
        uint256 _profit
    ) external override returns (uint256 send_) {
        require(
            isReserveToken[_token] || isLiquidityToken[_token],
            'Not accepted'
        );
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

        if (isReserveToken[_token]) {
            require(isReserveDepositor[msg.sender], 'Not approved');
        } else {
            require(isLiquidityDepositor[msg.sender], 'Not approved');
        }

        uint256 value = valueOfToken(_token, _amount);
        send_ = value.sub(_profit);
        IERC20Mintable(CLAM).mint(msg.sender, send_);

        totalReserves = totalReserves.add(value);
        emit ReservesUpdated(totalReserves);

        emit Deposit(_token, _amount, value);
    }

    function withdraw(uint256 _amount, address _token) external override {
        require(isReserveToken[_token], 'Not accepted');
        require(isReserveSpender[msg.sender] == true, 'Not approved');

        uint256 value = valueOfToken(_token, _amount);
        ICLAMERC20(CLAM).burnFrom(msg.sender, value);

        totalReserves = totalReserves.sub(value);
        emit ReservesUpdated(totalReserves);

        IERC20(_token).safeTransfer(msg.sender, _amount);

        emit Withdrawal(_token, _amount, value);
    }

    function incurDebt(uint256 _amount, address _token) external {
        require(isDebtor[msg.sender], 'Not approved');
        require(isReserveToken[_token], 'Not accepted');

        uint256 value = valueOfToken(_token, _amount);

        uint256 maximumDebt = IERC20(sCLAM).balanceOf(msg.sender);
        uint256 availableDebt = maximumDebt.sub(debtorBalance[msg.sender]);
        require(value <= availableDebt, 'Exceeds debt limit');

        debtorBalance[msg.sender] = debtorBalance[msg.sender].add(value);
        totalDebt = totalDebt.add(value);

        totalReserves = totalReserves.sub(value);
        emit ReservesUpdated(totalReserves);

        IERC20(_token).transfer(msg.sender, _amount);

        emit CreateDebt(msg.sender, _token, _amount, value);
    }

    function repayDebtWithReserve(uint256 _amount, address _token) external {
        require(isDebtor[msg.sender], 'Not approved');
        require(isReserveToken[_token], 'Not accepted');

        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

        uint256 value = valueOfToken(_token, _amount);
        debtorBalance[msg.sender] = debtorBalance[msg.sender].sub(value);
        totalDebt = totalDebt.sub(value);

        totalReserves = totalReserves.add(value);
        emit ReservesUpdated(totalReserves);

        emit RepayDebt(msg.sender, _token, _amount, value);
    }

    function repayDebtWithCLAM(uint256 _amount) external {
        require(isDebtor[msg.sender], 'Not approved');

        ICLAMERC20(CLAM).burnFrom(msg.sender, _amount);

        debtorBalance[msg.sender] = debtorBalance[msg.sender].sub(_amount);
        totalDebt = totalDebt.sub(_amount);

        emit RepayDebt(msg.sender, CLAM, _amount, _amount);
    }

    function manage(address _token, uint256 _amount) external override {
        if (isLiquidityToken[_token]) {
            require(isLiquidityManager[msg.sender], 'Not approved');
        } else {
            require(isReserveManager[msg.sender], 'Not approved');
        }

        uint256 value = valueOfToken(_token, _amount);
        require(value <= excessReserves(), 'Insufficient reserves');

        totalReserves = totalReserves.sub(value);
        emit ReservesUpdated(totalReserves);

        IERC20(_token).safeTransfer(msg.sender, _amount);

        emit ReservesManaged(_token, _amount);
    }

    function mintRewards(address _recipient, uint256 _amount)
        external
        override
    {
        require(isRewardManager[msg.sender], 'Not approved');
        require(_amount <= excessReserves(), 'Insufficient reserves');

        IERC20Mintable(CLAM).mint(_recipient, _amount);

        emit RewardsMinted(msg.sender, _recipient, _amount);
    }

    function excessReserves() public view override returns (uint256) {
        return totalReserves.sub(IERC20(CLAM).totalSupply().sub(totalDebt));
    }

    function auditReserves() external onlyOwner {
        uint256 reserves;
        for (uint256 i = 0; i < reserveTokens.length; i++) {
            reserves = reserves.add(
                valueOfToken(
                    reserveTokens[i],
                    IERC20(reserveTokens[i]).balanceOf(address(this))
                )
            );
        }
        for (uint256 i = 0; i < liquidityTokens.length; i++) {
            reserves = reserves.add(
                valueOfToken(
                    liquidityTokens[i],
                    IERC20(liquidityTokens[i]).balanceOf(address(this))
                )
            );
        }
        totalReserves = reserves;
        emit ReservesUpdated(reserves);
        emit ReservesAudited(reserves);
    }

    function valueOfToken(address _token, uint256 _amount)
        public
        view
        override
        returns (uint256 value_)
    {
        if (isReserveToken[_token]) {
            value_ = _amount.mul(10**IERC20(CLAM).decimals()).div(
                10**IERC20(_token).decimals()
            );
        } else if (isLiquidityToken[_token]) {
            value_ = IBondCalculator(bondCalculator[_token]).valuation(
                _token,
                _amount
            );
        }
    }

    function queue(MANAGING _managing, address _address)
        external
        onlyOwner
        returns (bool)
    {
        require(_address != address(0));
        if (_managing == MANAGING.RESERVEDEPOSITOR) {
            reserveDepositorQueue[_address] = block.number.add(
                blocksNeededForQueue
            );
        } else if (_managing == MANAGING.RESERVESPENDER) {
            reserveSpenderQueue[_address] = block.number.add(
                blocksNeededForQueue
            );
        } else if (_managing == MANAGING.RESERVETOKEN) {
            reserveTokenQueue[_address] = block.number.add(
                blocksNeededForQueue
            );
        } else if (_managing == MANAGING.RESERVEMANAGER) {
            ReserveManagerQueue[_address] = block.number.add(
                blocksNeededForQueue.mul(2)
            );
        } else if (_managing == MANAGING.LIQUIDITYDEPOSITOR) {
            LiquidityDepositorQueue[_address] = block.number.add(
                blocksNeededForQueue
            );
        } else if (_managing == MANAGING.LIQUIDITYTOKEN) {
            LiquidityTokenQueue[_address] = block.number.add(
                blocksNeededForQueue
            );
        } else if (_managing == MANAGING.LIQUIDITYMANAGER) {
            LiquidityManagerQueue[_address] = block.number.add(
                blocksNeededForQueue.mul(2)
            );
        } else if (_managing == MANAGING.DEBTOR) {
            debtorQueue[_address] = block.number.add(blocksNeededForQueue);
        } else if (_managing == MANAGING.REWARDMANAGER) {
            rewardManagerQueue[_address] = block.number.add(
                blocksNeededForQueue
            );
        } else if (_managing == MANAGING.SCLAM) {
            sCLAMQueue = block.number.add(blocksNeededForQueue);
        } else return false;

        emit ChangeQueued(_managing, _address);
        return true;
    }

    function toggle(
        MANAGING _managing,
        address _address,
        address _calculator
    ) external onlyOwner returns (bool) {
        require(_address != address(0));
        bool result;
        if (_managing == MANAGING.RESERVEDEPOSITOR) {
            if (
                requirements(
                    reserveDepositorQueue,
                    isReserveDepositor,
                    _address
                )
            ) {
                reserveDepositorQueue[_address] = 0;
                if (!listContains(reserveDepositors, _address)) {
                    reserveDepositors.push(_address);
                }
            }
            result = !isReserveDepositor[_address];
            isReserveDepositor[_address] = result;
        } else if (_managing == MANAGING.RESERVESPENDER) {
            if (requirements(reserveSpenderQueue, isReserveSpender, _address)) {
                reserveSpenderQueue[_address] = 0;
                if (!listContains(reserveSpenders, _address)) {
                    reserveSpenders.push(_address);
                }
            }
            result = !isReserveSpender[_address];
            isReserveSpender[_address] = result;
        } else if (_managing == MANAGING.RESERVETOKEN) {
            if (requirements(reserveTokenQueue, isReserveToken, _address)) {
                reserveTokenQueue[_address] = 0;
                if (!listContains(reserveTokens, _address)) {
                    reserveTokens.push(_address);
                }
            }
            result = !isReserveToken[_address];
            isReserveToken[_address] = result;
        } else if (_managing == MANAGING.RESERVEMANAGER) {
            if (requirements(ReserveManagerQueue, isReserveManager, _address)) {
                reserveManagers.push(_address);
                ReserveManagerQueue[_address] = 0;
                if (!listContains(reserveManagers, _address)) {
                    reserveManagers.push(_address);
                }
            }
            result = !isReserveManager[_address];
            isReserveManager[_address] = result;
        } else if (_managing == MANAGING.LIQUIDITYDEPOSITOR) {
            if (
                requirements(
                    LiquidityDepositorQueue,
                    isLiquidityDepositor,
                    _address
                )
            ) {
                liquidityDepositors.push(_address);
                LiquidityDepositorQueue[_address] = 0;
                if (!listContains(liquidityDepositors, _address)) {
                    liquidityDepositors.push(_address);
                }
            }
            result = !isLiquidityDepositor[_address];
            isLiquidityDepositor[_address] = result;
        } else if (_managing == MANAGING.LIQUIDITYTOKEN) {
            if (requirements(LiquidityTokenQueue, isLiquidityToken, _address)) {
                LiquidityTokenQueue[_address] = 0;
                if (!listContains(liquidityTokens, _address)) {
                    liquidityTokens.push(_address);
                }
            }
            result = !isLiquidityToken[_address];
            isLiquidityToken[_address] = result;
            bondCalculator[_address] = _calculator;
        } else if (_managing == MANAGING.LIQUIDITYMANAGER) {
            if (
                requirements(
                    LiquidityManagerQueue,
                    isLiquidityManager,
                    _address
                )
            ) {
                LiquidityManagerQueue[_address] = 0;
                if (!listContains(liquidityManagers, _address)) {
                    liquidityManagers.push(_address);
                }
            }
            result = !isLiquidityManager[_address];
            isLiquidityManager[_address] = result;
        } else if (_managing == MANAGING.DEBTOR) {
            if (requirements(debtorQueue, isDebtor, _address)) {
                debtorQueue[_address] = 0;
                if (!listContains(debtors, _address)) {
                    debtors.push(_address);
                }
            }
            result = !isDebtor[_address];
            isDebtor[_address] = result;
        } else if (_managing == MANAGING.REWARDMANAGER) {
            if (requirements(rewardManagerQueue, isRewardManager, _address)) {
                rewardManagerQueue[_address] = 0;
                if (!listContains(rewardManagers, _address)) {
                    rewardManagers.push(_address);
                }
            }
            result = !isRewardManager[_address];
            isRewardManager[_address] = result;
        } else if (_managing == MANAGING.SCLAM) {
            sCLAMQueue = 0;
            sCLAM = _address;
            result = true;
        } else return false;

        emit ChangeActivated(_managing, _address, result);
        return true;
    }

    function requirements(
        mapping(address => uint256) storage queue_,
        mapping(address => bool) storage status_,
        address _address
    ) internal view returns (bool) {
        if (!status_[_address]) {
            require(queue_[_address] != 0, 'Must queue');
            require(queue_[_address] <= block.number, 'Queue not expired');
            return true;
        }
        return false;
    }

    function listContains(address[] storage _list, address _token)
        internal
        view
        returns (bool)
    {
        for (uint256 i = 0; i < _list.length; i++) {
            if (_list[i] == _token) {
                return true;
            }
        }
        return false;
    }
}