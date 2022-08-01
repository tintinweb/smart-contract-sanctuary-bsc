// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity 0.7.6;

import "./helpers/SafeMath.sol";
import "./Auth.sol";
import "./helpers/TransferHelper.sol";
import "./USDP.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/IVault.sol";


/**
 * @title Vault
 * @notice Vault is the core of Unit Protocol USDP Stablecoin system
 * @notice Vault stores and manages collateral funds of all positions and counts debts
 * @notice Only Vault can manage supply of USDP token
 * @notice Vault will not be changed/upgraded after initial deployment for the current stablecoin version
 **/
contract Vault is IVault, Auth {
    using SafeMath for uint;

    // WETH token address
    address payable public immutable override weth;

    uint public constant override DENOMINATOR_1E5 = 1e5;
    uint public constant override DENOMINATOR_1E2 = 1e2;

    // USDP token address
    address public immutable override usdp;

    // collaterals whitelist
    mapping(address => mapping(address => uint)) public override collaterals;

    // user debts
    mapping(address => mapping(address => uint)) public override debts;

    // block number of liquidation trigger
    mapping(address => mapping(address => uint)) public override liquidationTs;

    // initial price of collateral
    mapping(address => mapping(address => uint)) public override liquidationPrice;

    // debts of tokens
    mapping(address => uint) public override tokenDebts;

    // stability fee pinned to each position
    mapping(address => mapping(address => uint)) public override stabilityFee;

    // accumulated stability fee pinned to each position
    mapping(address => mapping(address => uint)) public accumulatedStabilityFee;

    // liquidation fee pinned to each position, 0 decimals
    mapping(address => mapping(address => uint)) public override liquidationFee;

    // type of using oracle pinned for each position
    mapping(address => mapping(address => uint)) public override oracleType;

    // timestamp of the last update
    mapping(address => mapping(address => uint)) public override lastUpdate;

    modifier notLiquidating(address asset, address user) {
        require(liquidationTs[asset][user] == 0, "Unit Protocol: LIQUIDATING_POSITION");
        _;
    }

    modifier checkpointFee(address asset, address user) {
        accumulatedStabilityFee[asset][user] = getFee(asset, user);
        lastUpdate[asset][user] = block.timestamp;
        _;
    }

    /**
     * @param _parameters The address of the system parameters
     * @param _usdp USDP token address
     * @param _weth WETH token address
     **/
    constructor(address _parameters, address _usdp, address payable _weth) Auth(_parameters) {
        usdp = _usdp;
        weth = _weth;
    }

    // only accept ETH via fallback from the WETH contract
    receive() external payable {
        require(msg.sender == weth, "Unit Protocol: RESTRICTED");
    }

    /**
     * @dev Updates parameters of the position to the current ones
     * @param asset The address of the main collateral token
     * @param user The owner of a position
     **/
    function update(address asset, address user) public override hasVaultAccess notLiquidating(asset, user) checkpointFee(asset, user) {
        stabilityFee[asset][user] = vaultParameters.stabilityFee(asset);
        liquidationFee[asset][user] = vaultParameters.liquidationFee(asset);
    }

    /**
     * @dev Creates new position for user
     * @param asset The address of the main collateral token
     * @param user The address of a position's owner
     * @param _oracleType The type of an oracle
     **/
    function spawn(address asset, address user, uint _oracleType) external override hasVaultAccess notLiquidating(asset, user) {
        oracleType[asset][user] = _oracleType;
    }

    /**
     * @dev Clears unused storage variables
     * @param asset The address of the main collateral token
     * @param user The address of a position's owner
     **/
    function destroy(address asset, address user) public override hasVaultAccess notLiquidating(asset, user) {
        delete stabilityFee[asset][user];
        delete accumulatedStabilityFee[asset][user];
        delete oracleType[asset][user];
        delete lastUpdate[asset][user];
        delete liquidationFee[asset][user];
    }

    /**
     * @notice Tokens must be pre-approved
     * @dev Adds main collateral to a position
     * @param asset The address of the main collateral token
     * @param user The address of a position's owner
     * @param amount The amount of tokens to deposit
     **/
    function depositMain(address asset, address user, uint amount) external override hasVaultAccess notLiquidating(asset, user) {
        collaterals[asset][user] = collaterals[asset][user].add(amount);
        TransferHelper.safeTransferFrom(asset, user, address(this), amount);
    }

    /**
     * @dev Converts ETH to WETH and adds main collateral to a position
     * @param user The address of a position's owner
     **/
    function depositEth(address user) external override payable notLiquidating(weth, user) {
        IWETH(weth).deposit{value: msg.value}();
        collaterals[weth][user] = collaterals[weth][user].add(msg.value);
    }

    /**
     * @dev Withdraws main collateral from a position
     * @param asset The address of the main collateral token
     * @param user The address of a position's owner
     * @param amount The amount of tokens to withdraw
     **/
    function withdrawMain(address asset, address user, uint amount) external override hasVaultAccess notLiquidating(asset, user) {
        collaterals[asset][user] = collaterals[asset][user].sub(amount);
        TransferHelper.safeTransfer(asset, user, amount);
    }

    /**
     * @dev Withdraws WETH collateral from a position converting WETH to ETH
     * @param user The address of a position's owner
     * @param amount The amount of ETH to withdraw
     **/
    function withdrawEth(address payable user, uint amount) external override hasVaultAccess notLiquidating(weth, user) {
        collaterals[weth][user] = collaterals[weth][user].sub(amount);
        IWETH(weth).withdraw(amount);
        TransferHelper.safeTransferETH(user, amount);
    }

    /**
     * @dev Increases position's debt and mints USDP token
     * @param asset The address of the main collateral token
     * @param user The address of a position's owner
     * @param amount The amount of USDP to borrow
     **/
    function borrow(
        address asset,
        address user,
        uint amount
    )
    external
    override
    hasVaultAccess
    notLiquidating(asset, user)
    returns(uint)
    {
        require(vaultParameters.isOracleTypeEnabled(oracleType[asset][user], asset), "Unit Protocol: WRONG_ORACLE_TYPE");
        update(asset, user);
        debts[asset][user] = debts[asset][user].add(amount);
        tokenDebts[asset] = tokenDebts[asset].add(amount);

        // check USDP limit for token
        require(tokenDebts[asset] <= vaultParameters.tokenDebtLimit(asset), "Unit Protocol: ASSET_DEBT_LIMIT");

        USDP(usdp).mint(user, amount);

        return debts[asset][user];
    }

    /**
     * @dev Decreases position's debt and burns USDP token
     * @param asset The address of the main collateral token
     * @param user The address of a position's owner
     * @param amount The amount of USDP to repay
     * @return updated debt of a position
     **/
    function repay(
        address asset,
        address user,
        uint amount
    )
    external
    override
    hasVaultAccess
    notLiquidating(asset, user)
    checkpointFee(asset, user)
    returns(uint)
    {
        uint debt = debts[asset][user];
        debts[asset][user] = debt.sub(amount);
        tokenDebts[asset] = tokenDebts[asset].sub(amount);
        USDP(usdp).burn(user, amount);

        return debts[asset][user].add(accumulatedStabilityFee[asset][user]);
    }

    /**
     * @dev Transfers fee to foundation
     * @param asset The address of the fee asset
     * @param user The address to transfer funds from
     * @param amount The amount of asset to transfer
     **/
    function chargeFee(address asset, address user, uint amount) external override hasVaultAccess notLiquidating(asset, user) {
        if (amount != 0) {
            TransferHelper.safeTransferFrom(asset, user, vaultParameters.foundation(), amount);
        }
    }

    /**
     * @dev Decreases accumulated fee
     * @param asset The address of the collateral
     * @param user The address of the position owner
     * @param amount The amount of fee
     **/
    function decreaseFee(
      address asset,
      address user,
      uint amount
    )
    external
    override
    hasVaultAccess
    notLiquidating(asset, user)
    checkpointFee(asset, user)
    {
        accumulatedStabilityFee[asset][user] = accumulatedStabilityFee[asset][user].sub(amount);
    }

    /**
     * @dev Deletes position and transfers collateral to liquidation system
     * @param asset The address of the main collateral token
     * @param positionOwner The address of a position's owner
     * @param initialPrice The starting price of collateral in USDP
     **/
    function triggerLiquidation(
        address asset,
        address positionOwner,
        uint initialPrice
    )
    external
    override
    hasVaultAccess
    notLiquidating(asset, positionOwner)
    checkpointFee(asset, positionOwner)
    {
        // reverts if oracle type is disabled
        require(vaultParameters.isOracleTypeEnabled(oracleType[asset][positionOwner], asset), "Unit Protocol: WRONG_ORACLE_TYPE");

        liquidationTs[asset][positionOwner] = block.timestamp;
        liquidationPrice[asset][positionOwner] = initialPrice;
    }

    /**
     * @dev Internal liquidation process
     * @param asset The address of the main collateral token
     * @param positionOwner The address of a position's owner
     * @param mainAssetToLiquidator The amount of main asset to send to a liquidator
     * @param mainAssetToPositionOwner The amount of main asset to send to a position owner
     * @param repayment The repayment in USDP
     * @param penalty The liquidation penalty in USDP
     * @param liquidator The address of a liquidator
     **/
    function liquidate(
        address asset,
        address positionOwner,
        uint mainAssetToLiquidator,
        uint mainAssetToPositionOwner,
        uint repayment,
        uint penalty,
        address liquidator
    )
        external
        override
        hasVaultAccess
    {
        require(liquidationTs[asset][positionOwner] != 0, "Unit Protocol: NOT_TRIGGERED_LIQUIDATION");

        uint mainAssetInPosition = collaterals[asset][positionOwner];
        uint mainAssetToFoundation = mainAssetInPosition.sub(mainAssetToLiquidator).sub(mainAssetToPositionOwner);

        tokenDebts[asset] = tokenDebts[asset].sub(debts[asset][positionOwner]);

        delete liquidationPrice[asset][positionOwner];
        delete liquidationTs[asset][positionOwner];
        delete debts[asset][positionOwner];
        delete collaterals[asset][positionOwner];

        destroy(asset, positionOwner);

        // charge liquidation fee and burn USDP
        if (repayment > penalty) {
            if (penalty != 0) {
                TransferHelper.safeTransferFrom(usdp, liquidator, vaultParameters.foundation(), penalty);
            }
            USDP(usdp).burn(liquidator, repayment.sub(penalty));
        } else {
            if (repayment != 0) {
                TransferHelper.safeTransferFrom(usdp, liquidator, vaultParameters.foundation(), repayment);
            }
        }

        // send the part of collateral to a liquidator
        if (mainAssetToLiquidator != 0) {
            TransferHelper.safeTransfer(asset, liquidator, mainAssetToLiquidator);
        }

        // send the rest of collateral to a position owner
        if (mainAssetToPositionOwner != 0) {
            TransferHelper.safeTransfer(asset, positionOwner, mainAssetToPositionOwner);
        }

        if (mainAssetToFoundation != 0) {
            TransferHelper.safeTransfer(asset, vaultParameters.foundation(), mainAssetToFoundation);
        }
    }

    /**
     * @notice Only manager can call this function
     * @dev Changes broken oracle type to the correct one
     * @param asset The address of the main collateral token
     * @param user The address of a position's owner
     * @param newOracleType The new type of an oracle
     **/
    function changeOracleType(address asset, address user, uint newOracleType) external override onlyManager {
        oracleType[asset][user] = newOracleType;
        emit OracleTypeChanged(asset, user, newOracleType);
    }

    /**
     * @dev Calculates the total amount of position's debt based on elapsed time
     * @param asset The address of the main collateral token
     * @param user The address of a position's owner
     * @return user debt of a position plus accumulated fee
     **/
    function getTotalDebt(address asset, address user) public override view returns (uint) {
        return debts[asset][user].add(getFee(asset, user));
    }

    /**
     * @dev Calculates the total amount of position's fee
     * @param asset The address of the main collateral
     * @param user The address of a position's owner
     * @return user accumulated fee
     **/
    function getFee(address asset, address user) public override view returns (uint) {
        if (liquidationTs[asset][user] != 0) return accumulatedStabilityFee[asset][user];
        return accumulatedStabilityFee[asset][user].add(calculateFee(asset, user, debts[asset][user]));
    }

    /**
     * @dev Calculates the amount of fee based on elapsed time and repayment amount
     * @param asset The address of the main collateral token
     * @param user The address of a position's owner
     * @param amount The repayment amount
     * @return fee amount
     **/
    function calculateFee(address asset, address user, uint amount) internal view returns (uint) {
        uint sFeePercent = stabilityFee[asset][user];
        uint timePast = block.timestamp.sub(lastUpdate[asset][user]);

        return amount.mul(sFeePercent).mul(timePast).div(365 days).div(DENOMINATOR_1E5);
    }
}

// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity 0.7.6;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity 0.7.6;

import "./interfaces/IVaultParameters.sol";
import "./interfaces/IWithVaultParameters.sol";

/**
 * @title Auth
 * @dev Manages USDP's system access
 **/
contract Auth is IWithVaultParameters {

    // address of the the contract with vault parameters
    IVaultParameters public immutable override vaultParameters;

    constructor(address _parameters) {
        vaultParameters = IVaultParameters(_parameters);
    }

    // ensures tx's sender is a manager
    modifier onlyManager() {
        require(vaultParameters.isManager(msg.sender), "Unit Protocol: AUTH_FAILED");
        _;
    }

    // ensures tx's sender is able to modify the Vault
    modifier hasVaultAccess() {
        require(vaultParameters.canModifyVault(msg.sender), "Unit Protocol: AUTH_FAILED");
        _;
    }

    // ensures tx's sender is the Vault
    modifier onlyVault() {
        require(msg.sender == vaultParameters.vault(), "Unit Protocol: AUTH_FAILED");
        _;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity 0.7.6;

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

// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity 0.7.6;

import "./Auth.sol";
import "./helpers/SafeMath.sol";


/**
 * @title USDP token implementation
 * @dev ERC20 token
 **/
contract USDP is Auth {
    using SafeMath for uint;

    // name of the token
    string public constant name = "USDP Stablecoin";

    // symbol of the token
    string public constant symbol = "USDP";

    // version of the token
    string public constant version = "1";

    // number of decimals the token uses
    uint8 public constant decimals = 18;

    // total token supply
    uint public totalSupply;

    // balance information map
    mapping(address => uint) public balanceOf;

    // token allowance mapping
    mapping(address => mapping(address => uint)) public allowance;

    // minters mapping
    mapping(address => bool) public isMinter;

    /**
     * @dev Trigger on any successful call to approve(address spender, uint amount)
    **/
    event Approval(address indexed owner, address indexed spender, uint value);

    /**
     * @dev Trigger when tokens are transferred, including zero value transfers
    **/
    event Transfer(address indexed from, address indexed to, uint value);

    /**
     * @dev Trigger minter is set/unset
    **/
    event Minter(address indexed who, bool flag);

    modifier onlyMinter() {
        require(isMinter[msg.sender], "Unit Protocol: NOT_A_MINTER");
        _;
    }

    /**
      * @param _parameters The address of system parameters contract
     **/
    constructor(address _parameters) Auth(_parameters) {}

    /**
      * @notice Only manager is able to manage minters
      * @dev Allows and disallows 'who' to mint/burn the token
      * @param who The address of the minter
      * @param flag The permission flag
     **/
    function setMinter(address who, bool flag) external onlyManager {
        isMinter[who] = flag;
        emit Minter(who, flag);
    }

    /**
      * @notice Only minter can mint USDP
      * @dev Mints 'amount' of tokens to address 'to', and MUST fire the
      * Transfer event
      * @param to The address of the recipient
      * @param amount The amount of token to be minted
     **/
    function mint(address to, uint amount) external onlyMinter {
        require(to != address(0), "Unit Protocol: ZERO_ADDRESS");

        balanceOf[to] = balanceOf[to].add(amount);
        totalSupply = totalSupply.add(amount);

        emit Transfer(address(0), to, amount);
    }

    /**
      * @notice Only manager can burn tokens from manager's balance
      * @dev Burns 'amount' of tokens, and MUST fire the Transfer event
      * @param amount The amount of token to be burned
     **/
    function burn(uint amount) external onlyManager {
        _burn(msg.sender, amount);
    }

    /**
      * @notice Only minter can burn tokens from any address
      * @dev Burns 'amount' of tokens from 'from' address, and MUST fire the Transfer event
      * @param from The address of the balance owner
      * @param amount The amount of token to be burned
     **/
    function burn(address from, uint amount) external onlyMinter {
        _burn(from, amount);
    }

    /**
      * @dev Transfers 'amount' of tokens to address 'to', and MUST fire the Transfer event. The
      * function SHOULD throw if the _from account balance does not have enough tokens to spend.
      * @param to The address of the recipient
      * @param amount The amount of token to be transferred
     **/
    function transfer(address to, uint amount) external returns (bool) {
        return transferFrom(msg.sender, to, amount);
    }

    /**
      * @dev Transfers 'amount' of tokens from address 'from' to address 'to', and MUST fire the
      * Transfer event
      * @param from The address of the sender
      * @param to The address of the recipient
      * @param amount The amount of token to be transferred
     **/
    function transferFrom(address from, address to, uint amount) public returns (bool) {
        require(to != address(0), "Unit Protocol: ZERO_ADDRESS");
        require(balanceOf[from] >= amount, "Unit Protocol: INSUFFICIENT_BALANCE");

        if (from != msg.sender) {
            require(allowance[from][msg.sender] >= amount, "Unit Protocol: INSUFFICIENT_ALLOWANCE");
            _approve(from, msg.sender, allowance[from][msg.sender].sub(amount));
        }
        balanceOf[from] = balanceOf[from].sub(amount);
        balanceOf[to] = balanceOf[to].add(amount);

        emit Transfer(from, to, amount);
        return true;
    }

    /**
      * @dev Allows 'spender' to withdraw from your account multiple times, up to the 'amount' amount. If
      * this function is called again it overwrites the current allowance with 'amount'.
      * @param spender The address of the account able to transfer the tokens
      * @param amount The amount of tokens to be approved for transfer
     **/
    function approve(address spender, uint amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, allowance[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, allowance[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _approve(address owner, address spender, uint amount) internal virtual {
        require(owner != address(0), "Unit Protocol: approve from the zero address");
        require(spender != address(0), "Unit Protocol: approve to the zero address");

        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burn(address from, uint amount) internal virtual {
        balanceOf[from] = balanceOf[from].sub(amount);
        totalSupply = totalSupply.sub(amount);

        emit Transfer(from, address(0), amount);
    }
}

// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity ^0.7.6;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity ^0.7.6;

interface IVault {
    event OracleTypeChanged(address indexed asset, address indexed user, uint newOracleType);

    function DENOMINATOR_1E2 (  ) external view returns ( uint256 );
    function DENOMINATOR_1E5 (  ) external view returns ( uint256 );
    function borrow ( address asset, address user, uint256 amount ) external returns ( uint256 );
    function changeOracleType ( address asset, address user, uint256 newOracleType ) external;
    function chargeFee ( address asset, address user, uint256 amount ) external;
    function decreaseFee ( address asset, address user, uint amount ) external;
    function collaterals ( address, address ) external view returns ( uint256 );
    function debts ( address, address ) external view returns ( uint256 );
    function getFee ( address, address ) external view returns ( uint256 );
    function depositEth ( address user ) external payable;
    function depositMain ( address asset, address user, uint256 amount ) external;
    function destroy ( address asset, address user ) external;
    function getTotalDebt ( address asset, address user ) external view returns ( uint256 );
    function lastUpdate ( address, address ) external view returns ( uint256 );
    function liquidate ( address asset, address positionOwner, uint256 mainAssetToLiquidator, uint256 mainAssetToPositionOwner, uint256 repayment, uint256 penalty, address liquidator ) external;
    function liquidationTs ( address, address ) external view returns ( uint256 );
    function liquidationFee ( address, address ) external view returns ( uint256 );
    function liquidationPrice ( address, address ) external view returns ( uint256 );
    function oracleType ( address, address ) external view returns ( uint256 );
    function repay ( address asset, address user, uint256 amount ) external returns ( uint256 );
    function spawn ( address asset, address user, uint256 _oracleType ) external;
    function stabilityFee ( address, address ) external view returns ( uint256 );
    function tokenDebts ( address ) external view returns ( uint256 );
    function triggerLiquidation ( address asset, address positionOwner, uint256 initialPrice ) external;
    function update ( address asset, address user ) external;
    function usdp (  ) external view returns ( address );
    function weth (  ) external view returns ( address payable );
    function withdrawEth ( address payable user, uint256 amount ) external;
    function withdrawMain ( address asset, address user, uint256 amount ) external;
}

// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity ^0.7.6;

interface IVaultParameters {
    event ManagerAdded(address indexed who);
    event ManagerRemoved(address indexed who);
    event FoundationChanged(address indexed newFoundation);
    event VaultAccessGranted(address indexed who);
    event VaultAccessRevoked(address indexed who);
    event StabilityFeeChanged(address indexed asset, uint newValue);
    event LiquidationFeeChanged(address indexed asset, uint newValue);
    event OracleTypeEnabled(address indexed asset, uint _type);
    event OracleTypeDisabled(address indexed asset, uint _type);
    event TokenDebtLimitChanged(address indexed asset, uint limit);

    function canModifyVault ( address ) external view returns ( bool );
    function foundation (  ) external view returns ( address );
    function isManager ( address ) external view returns ( bool );
    function isOracleTypeEnabled ( uint256, address ) external view returns ( bool );
    function liquidationFee ( address ) external view returns ( uint256 );
    function setCollateral ( address asset, uint256 stabilityFeeValue, uint256 liquidationFeeValue, uint256 usdpLimit, uint256[] calldata oracles ) external;
    function setFoundation ( address newFoundation ) external;
    function setLiquidationFee ( address asset, uint256 newValue ) external;
    function setManager ( address who, bool permit ) external;
    function setOracleType ( uint256 _type, address asset, bool enabled ) external;
    function setStabilityFee ( address asset, uint256 newValue ) external;
    function setTokenDebtLimit ( address asset, uint256 limit ) external;
    function setVaultAccess ( address who, bool permit ) external;
    function stabilityFee ( address ) external view returns ( uint256 );
    function tokenDebtLimit ( address ) external view returns ( uint256 );
    function vault (  ) external view returns ( address payable );
}

// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2021 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity ^0.7.6;

import "./IVaultParameters.sol";

interface IWithVaultParameters {
    function vaultParameters (  ) external view returns ( IVaultParameters );
}