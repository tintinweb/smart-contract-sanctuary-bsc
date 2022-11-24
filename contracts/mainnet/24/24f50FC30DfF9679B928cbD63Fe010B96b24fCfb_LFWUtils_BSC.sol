// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function totalSupply() external view returns (uint256);
    function getReserves() external view returns (uint112, uint112, uint32);
}

interface IPancakeStakingInterface {
    function pendingReward(address _user) external view returns (uint256);
    function bonusEndBlock() external view returns (uint256);
    function lastRewardBlock() external view returns (uint256);
    function rewardPerBlock() external view returns (uint256);
    function stakedToken() external view returns (address);
    function userInfo(address _user) external view returns (uint256, uint256);
}

interface IPancakeFarmingInterface {
    function poolInfo(uint256 _pId) external view returns (uint256, uint256, uint256, uint256, bool);
    function lpToken(uint256 _pId) external view returns (address);
    function cakePerBlock(bool _isRegular) external view returns (uint256);
    function pendingCake(uint256 _pId, address _user) external view returns (uint256);
    function userInfo(uint256 _pId, address _user) external view returns (uint256, uint256, uint256);
}

interface IApeStakingInterface {
    function pendingReward(address _user) external view returns (uint256);
    function bonusEndBlock() external view returns (uint256);
    function rewardPerBlock() external view returns (uint256);
    function STAKE_TOKEN() external view returns (address);
    function userInfo(address _user) external view returns (uint256, uint256);
}

interface IApeBananaFarmingInterface {
    function cakePerBlock() external view returns (uint256);
    function pendingCake(uint256 _pId, address _user) external view returns (uint256);
    function userInfo(uint256 _pId, address _user) external view returns (uint256, uint256);
    function poolInfo(uint256 _pId) external view returns (address, uint256, uint256, uint256);
}

interface IApeJungleFarmingInterface {
    function STAKE_TOKEN() external view returns (address);
    function REWARD_TOKEN() external view returns (address);
    function pendingReward(address _user) external view returns (uint256);
    function userInfo(address _user) external view returns (uint256, uint256);
}

interface IBabyStakingInterface {
    function pendingCake(uint256 _pId, address _user) external view returns (uint256);
    function cakePerBlock() external view returns (uint256);
    function cake() external view returns (address);
    function userInfo(uint256 _pId, address _user) external view returns (uint256, uint256);
}

interface IBabyFarmingInterface {
    function pendingCake(uint256 _pId, address _user) external view returns (uint256);
    function cakePerBlock() external view returns (uint256);
    function cake() external view returns (address);
    function userInfo(uint256 _pId, address _user) external view returns (uint256, uint256);
    function poolInfo(uint256 _pId) external view returns (address, uint256, uint256, uint256);
}

interface IBiswapStakingInterface {
    function userPendingWithdraw(address _user, address _token) external view returns (uint32);
    function userInfo(address, uint256 _pId) external view returns (uint128, uint128, uint32, bool);
    function pools(uint256 _pId) external view returns (address, uint32, uint32, uint16, uint16, uint128, uint128, uint128, uint128, uint128, bool);
    function getCurrentDay() external view returns (uint32);
}

interface IBiswapFarmingInterface {
    function pendingBSW(uint256 _pId, address _user) external view returns (uint256);
    function userInfo(uint256 _pId, address _user) external view returns (uint256, uint256);
    function poolInfo(uint256 _pId) external view returns (address, uint256, uint256, uint256);
}

interface IVenusVRTInterface {
    function userInfo(address _user) external view returns (address, uint256, uint256, uint256);
    function getAccruedInterest(address _user) external view returns (uint256);
}

interface IVenusVAIInterface {
    function userInfo(address _user) external view returns (uint256, uint256);
    function pendingXVS(address _user) external view returns (uint256);
}

interface IVenusXVSInterface {
    function getUserInfo(
        address _rewardToken, 
        uint256 _pId, 
        address _user
    ) external view returns (
        uint256, uint256, uint256
    );
    function pendingReward(
        address _rewardToken, 
        uint256 _pId, 
        address _user
    ) external view returns (uint256);
}

contract LFWUtils_BSC {
    uint private numStakingParameters = 5;
    uint private numFarmingParameters = 5;
    uint private numFarmingData = 3;
    address private pancakeFarmingPool = 0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652;
    address private apeFarmingPool = 0x5c8D727b265DBAfaba67E050f2f739cAeEB4A6F9;
    address private babyFarmingPool = 0xdfAa0e08e357dB0153927C7EaBB492d1F60aC730;
    address private biswapStakingPool = 0xa04adebaf9c96882C6d59281C23Df95AF710003e;
    address private biswapFarmingPool = 0xDbc1A13490deeF9c3C12b44FE77b503c1B061739;
    address private vrtVault = 0x98bF4786D72AAEF6c714425126Dd92f149e3F334;
    address private vaiVault = 0x0667Eed0a0aAb930af74a3dfeDD263A73994f216;
    address private xvsVault = 0x051100480289e704d20e9DB4804837068f3f9204;
    address private cake = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    address private banana = 0x603c7f932ED1fc6575303D8Fb018fDCBb0f39a95;
    address private baby = 0x53E562b9B7E5E94b81f10e96Ee70Ad06df3D2657;
    address private bsw = 0x965F527D9159dCe6288a2219DB51fc6Eef120dD1;
    uint private dailyBlock = 28800;
    uint private yearDay = 365;

    function getPancakeStakingInfo(
        address _scAddress, 
        address _userAddress
    ) public view returns(uint256[] memory stakingInfo) {
        // Define array to return
        stakingInfo = new uint256[](numStakingParameters);

        // Initialize interface
        IPancakeStakingInterface scInterface = IPancakeStakingInterface(_scAddress);

        // [0] is the user pending reward
        stakingInfo[0] = scInterface.pendingReward(_userAddress);

        // [1] is the user's staking amount
        (stakingInfo[1], ) = scInterface.userInfo(_userAddress);

        // [2] Calculate an optional term to calculate APR for backend
        uint256 rewardPerDay = scInterface.rewardPerBlock()*dailyBlock*yearDay;
        address stakedTokenAddress = scInterface.stakedToken();
        uint256 stakedTokenBalance = IERC20(stakedTokenAddress).balanceOf(_scAddress);
        stakingInfo[2] = rewardPerDay;
        stakingInfo[3] = stakedTokenBalance;

        // [3] is the pool countdown by block
        stakingInfo[4] = scInterface.bonusEndBlock() - block.number;
    }

    function getPancakeFarmingInfo(
        uint256 _pId,
        address _userAddress
    ) public view returns(uint256[] memory farmingInfo, address[] memory farmingData) {
        // Define array to return info
        farmingInfo = new uint256[](numFarmingParameters);

        // Define array to return data
        farmingData = new address[](numFarmingData);

        // Initialize interface
        IPancakeFarmingInterface scInterface = IPancakeFarmingInterface(pancakeFarmingPool);

        // [0] is the user pending reward
        farmingInfo[0] = scInterface.pendingCake(_pId, _userAddress);

        // [1] is the user's staking amount
        (farmingInfo[1], , ) = scInterface.userInfo(_pId, _userAddress);

        // [0] and [1] are token 0 and token 1
        address _lp = address(scInterface.lpToken(_pId));
        
        // Initialize interfacee
        IPair scPair = IPair(_lp);

        farmingData[0] = scPair.token0();
        farmingData[1] = scPair.token1();

        // [3] is the reward token address
        farmingData[2] = cake;

        (farmingInfo[2], farmingInfo[3], ) = scPair.getReserves();
        farmingInfo[4] = scPair.totalSupply();
    }

    function getApeStakingInfo(
        address _scAddress, 
        address _userAddress
    ) public view returns(uint256[] memory stakingInfo) {
        // Define array to return
        stakingInfo = new uint256[](numStakingParameters);

        // Initialize interface
        IApeStakingInterface scInterface = IApeStakingInterface(_scAddress);

        // [0] is the user pending reward
        stakingInfo[0] = scInterface.pendingReward(_userAddress);

        // [1] is the user's staking amount
        (stakingInfo[1], ) = scInterface.userInfo(_userAddress);

        // [2] Calculate an optional term to calculate APR for backend
        uint256 rewardPerDay = scInterface.rewardPerBlock()*dailyBlock*yearDay;
        address stakedTokenAddress = scInterface.STAKE_TOKEN();
        uint256 stakedTokenBalance = IERC20(stakedTokenAddress).balanceOf(_scAddress);
        stakingInfo[2] = rewardPerDay;
        stakingInfo[3] = stakedTokenBalance;
        // [3] is the pool countdown by block
        stakingInfo[4] = scInterface.bonusEndBlock() - block.number;
    }

    function getApeBANANAFarmingInfo(
        uint256 _pId, 
        address _userAddress
    ) public view returns(uint256[] memory farmingInfo, address[] memory farmingData) {
        // Define array to return
        farmingInfo = new uint256[](numFarmingParameters);

        // Define array to return data
        farmingData = new address[](numFarmingData);

        // Initialize interface
        IApeBananaFarmingInterface scInterface = IApeBananaFarmingInterface(apeFarmingPool);

        // [0] is the user pending reward
        farmingInfo[0] = scInterface.pendingCake(_pId, _userAddress);

        // [1] is the user's staking amount
        (farmingInfo[1], ) = scInterface.userInfo(_pId, _userAddress);

        // [0] and [1] are token 0 and token 1
        (address _lp, , , ) = scInterface.poolInfo(_pId);
        
        // Initialize interfacee
        IPair scPair = IPair(_lp);

        farmingData[0] = scPair.token0();
        farmingData[1] = scPair.token1();

        // [3] is the reward token address
        farmingData[2] = banana;

        (farmingInfo[2], farmingInfo[3], ) = scPair.getReserves();
        farmingInfo[4] = scPair.totalSupply();
    }

    function getApeJungleFarmingInnfo(
        address _scAddress,
        address _userAddress
    ) public view returns(uint256[] memory farmingInfo, address[] memory farmingData) {
        // Define array to return
        farmingInfo = new uint256[](numFarmingParameters);

        // Define array to return data
        farmingData = new address[](numFarmingData);

        // Initialize interface
        IApeJungleFarmingInterface scInterface = IApeJungleFarmingInterface(_scAddress);

        // [0] is the user pending reward
        farmingInfo[0] = scInterface.pendingReward(_userAddress);

        // [1] is the user's staking amount
        (farmingInfo[1], ) = scInterface.userInfo(_userAddress);

        // [0] and [1] are token 0 and token 1
        address _lp = scInterface.STAKE_TOKEN();
        
        // Initialize interfacee
        IPair scPair = IPair(_lp);

        farmingData[0] = scPair.token0();
        farmingData[1] = scPair.token1();

        // [3] is the reward token address
        farmingData[2] = scInterface.REWARD_TOKEN();

        (farmingInfo[2], farmingInfo[3], ) = scPair.getReserves();
        farmingInfo[4] = scPair.totalSupply();
    }

    function getBabyStakingInfo(
        address _scAddress, 
        address _userAddress
    ) public view returns(uint256[] memory stakingInfo) {
        // Define array to return
        stakingInfo = new uint256[](numStakingParameters);

        // Initialize interface
        IBabyStakingInterface scInterface = IBabyStakingInterface(_scAddress);

        // [0] is the user pending reward
        stakingInfo[0] = scInterface.pendingCake(0, _userAddress);

        // [1] is the user's staking amount
        (stakingInfo[1], ) = scInterface.userInfo(0, _userAddress);

        // [2] Calculate an optional term to calculate APR for backend
        uint256 rewardPerDay = scInterface.cakePerBlock()*dailyBlock*yearDay;
        address stakedTokenAddress = scInterface.cake();
        uint256 stakedTokenBalance = IERC20(stakedTokenAddress).balanceOf(_scAddress);
        stakingInfo[2] = rewardPerDay;
        stakingInfo[3] = stakedTokenBalance;

        // [3] is the pool countdown by block
        stakingInfo[4] = 0;
    }

    function getBabyFarmingInfo(
        uint256 _pId, 
        address _userAddress
    ) public view returns(uint256[] memory farmingInfo, address[] memory farmingData) {
        // Define array to return
        farmingInfo = new uint256[](numFarmingParameters);

        // Define array to return data
        farmingData = new address[](numFarmingData);

        // Initialize interface
        IBabyFarmingInterface scInterface = IBabyFarmingInterface(babyFarmingPool);

        // [0] is the user pending reward
        farmingInfo[0] = scInterface.pendingCake(_pId, _userAddress);

        // [1] is the user's staking amount
        (farmingInfo[1], ) = scInterface.userInfo(_pId, _userAddress);

        // [0] and [1] are token 0 and token 1
        (address _lp, , , ) = scInterface.poolInfo(_pId);

        // Initialize interfacee
        IPair scPair = IPair(_lp);

        farmingData[0] = scPair.token0();
        farmingData[1] = scPair.token1();

        // [3] is the reward token address
        farmingData[2] = baby;

        (farmingInfo[2], farmingInfo[3], ) = scPair.getReserves();
        farmingInfo[4] = scPair.totalSupply();
    }

    function getBiswapStakingInfo(
        uint256 _pId, 
        address _userAddress
    ) public view returns(uint256[] memory stakingInfo) {
        // Define array to return
        stakingInfo = new uint256[](numStakingParameters);

        // Initialize interface
        IBiswapStakingInterface scInterface = IBiswapStakingInterface(biswapStakingPool);

        // Get additional information
        (address tokenAddress, uint32 endDay, uint32 dayPercent, , , , , , , , ) = scInterface.pools(_pId);

        // [0] is the user pending reward
        stakingInfo[0] = scInterface.userPendingWithdraw(_userAddress, tokenAddress);

        // [1] is the user's staking amount
        (stakingInfo[1], , , ) = scInterface.userInfo(_userAddress, _pId);

        // [2] is the pool APR
        stakingInfo[2] = (dayPercent/1000000000)*365*100;

        // [3] is the pool countdown by block
        stakingInfo[3] = ((endDay - scInterface.getCurrentDay())*86400 - 43200);
    }

    function getBiswapFarmingInfo(
        uint256 _pId, 
        address _userAddress
    ) public view returns(uint256[] memory farmingInfo, address[] memory farmingData) {
        // Define array to return
        farmingInfo = new uint256[](numFarmingParameters);

        // Define array to return data
        farmingData = new address[](numFarmingData);

        // Initialize interface
        IBiswapFarmingInterface scInterface = IBiswapFarmingInterface(biswapFarmingPool);

        // [0] is the user pending reward
        farmingInfo[0] = scInterface.pendingBSW(_pId, _userAddress);

        // [1] is the user's staking amount
        (farmingInfo[1], ) = scInterface.userInfo(_pId, _userAddress);

       // [0] and [1] are token 0 and token 1
        (address _lp, , , ) = scInterface.poolInfo(_pId);

        // Initialize interfacee
        IPair scPair = IPair(_lp);

        farmingData[0] = scPair.token0();
        farmingData[1] = scPair.token1();

        // [3] is the reward token address
        farmingData[2] = bsw;

        (farmingInfo[2], farmingInfo[3], ) = scPair.getReserves();
        farmingInfo[4] = scPair.totalSupply();
    }


    function getVenusStakingInfo(
        address _scAddress,
        address _userAddress
    ) public view returns (uint256[] memory stakingInfo) {
        // Define array to return
        stakingInfo = new uint256[](numStakingParameters);
        // VRT Vault pool
        if (_scAddress == vrtVault) {
            // Initialize interface
            IVenusVRTInterface scInterface = IVenusVRTInterface(_scAddress); 
            stakingInfo[0] = scInterface.getAccruedInterest(_userAddress);
            ( , , stakingInfo[1], ) = scInterface.userInfo(_userAddress);
            stakingInfo[2] = 7816000000000000000000*365;
            // VRT address
            address stakedTokenAddress = 0x5F84ce30DC3cF7909101C69086c50De191895883; 
            uint256 stakedTokenBalance = IERC20(stakedTokenAddress).balanceOf(_scAddress);
            stakingInfo[3] = stakedTokenBalance;
            stakingInfo[4] = 0;
        } else if (_scAddress == vaiVault) {
            IVenusVAIInterface scInterface = IVenusVAIInterface(_scAddress); 
            stakingInfo[0] = scInterface.pendingXVS(_userAddress);
            (stakingInfo[1], ) = scInterface.userInfo(_userAddress);
            stakingInfo[2] = 250000000000000000000*365;
            // VRT address
            address stakedTokenAddress = 0x4BD17003473389A42DAF6a0a729f6Fdb328BbBd7; 
            uint256 stakedTokenBalance = IERC20(stakedTokenAddress).balanceOf(_scAddress);
            stakingInfo[3] = stakedTokenBalance;
            stakingInfo[4] = 0;            
        } else {
            IVenusXVSInterface scInterface = IVenusXVSInterface(_scAddress); 
            address _xvs = 0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63;
            stakingInfo[0] = scInterface.pendingReward(_xvs, 0, _userAddress);
            (stakingInfo[1], , ) = scInterface.getUserInfo(_xvs, 0, _userAddress);
            stakingInfo[2] = 3000000000000000000000*365;
            // VRT address
            uint256 stakedTokenBalance = IERC20(_xvs).balanceOf(_scAddress);
            stakingInfo[3] = stakedTokenBalance;
            stakingInfo[4] = 0;               
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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