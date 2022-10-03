/**
 *Submitted for verification at BscScan.com on 2021-02-26
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IVaultMaster {
    event UpdateBank(address bank, address vault);
    event UpdateVault(address vault, bool isAdd);
    event UpdateController(address controller, bool isAdd);
    event UpdateStrategy(address strategy, bool isAdd);

    function bank(address) view external returns (address);
    function isVault(address) view external returns (bool);
    function isController(address) view external returns (bool);
    function isStrategy(address) view external returns (bool);

    function slippage(address) view external returns (uint);
    function convertSlippage(address _input, address _output) view external returns (uint);

    function reserveFund() view external returns (address);
    function performanceReward() view external returns (address);

    function performanceFee() view external returns (uint);
    function gasFee() view external returns (uint);

    function withdrawalProtectionFee() view external returns (uint);
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract VSafeVaultMaster is IVaultMaster {
    address public governance;

    address public override reserveFund = 0x7Be4D5A99c903C437EC77A20CB6d0688cBB73c7f; // % profit from vSafe
    address public override performanceReward = 0x7Be4D5A99c903C437EC77A20CB6d0688cBB73c7f; // set to deploy wallet at start

    uint256 public override performanceFee = 500; // 5.0%
    uint256 public override gasFee = 0; // 0% at start and can be set by governance decision
    uint256 public override withdrawalProtectionFee = 0; // % of withdrawal go back to vault (for auto-compounding) to protect withdrawals

    mapping(address => address) public override bank;
    mapping(address => bool) public override isVault;
    mapping(address => bool) public override isController;
    mapping(address => bool) public override isStrategy;

    mapping(address => uint) public override slippage; // over 10000

    constructor() public {
        governance = msg.sender;
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setBank(address _vault, address _bank) external {
        require(msg.sender == governance, "!governance");
        bank[_vault] = _bank;
        emit UpdateBank(_bank, _vault);
    }

    function addVault(address _vault) external {
        require(msg.sender == governance, "!governance");
        isVault[_vault] = true;
        emit UpdateVault(_vault, true);
    }

    function removeVault(address _vault) external {
        require(msg.sender == governance, "!governance");
        isVault[_vault] = false;
        emit UpdateVault(_vault, false);
    }

    function addController(address _controller) external {
        require(msg.sender == governance, "!governance");
        isController[_controller] = true;
        emit UpdateController(_controller, true);
    }

    function removeController(address _controller) external {
        require(msg.sender == governance, "!governance");
        isController[_controller] = true;
        emit UpdateController(_controller, false);
    }

    function addStrategy(address _strategy) external {
        require(msg.sender == governance, "!governance");
        isStrategy[_strategy] = true;
        emit UpdateStrategy(_strategy, true);
    }

    function removeStrategy(address _strategy) external {
        require(msg.sender == governance, "!governance");
        isStrategy[_strategy] = false;
        emit UpdateStrategy(_strategy, false);
    }

    function setReserveFund(address _reserveFund) public {
        require(msg.sender == governance, "!governance");
        reserveFund = _reserveFund;
    }

    function setPerformanceReward(address _performanceReward) public {
        require(msg.sender == governance, "!governance");
        performanceReward = _performanceReward;
    }

    function setPerformanceFee(uint256 _performanceFee) public {
        require(msg.sender == governance, "!governance");
        require(_performanceFee <= 3000, "_performanceFee over 30%");
        performanceFee = _performanceFee;
    }

    function setGasFee(uint256 _gasFee) public {
        require(msg.sender == governance, "!governance");
        require(_gasFee <= 500, "_gasFee over 5%");
        gasFee = _gasFee;
    }

    function setWithdrawalProtectionFee(uint256 _withdrawalProtectionFee) public {
        require(msg.sender == governance, "!governance");
        require(_withdrawalProtectionFee <= 100, "_withdrawalProtectionFee over 1%");
        withdrawalProtectionFee = _withdrawalProtectionFee;
    }

    function setSlippage(address _token, uint _slippage) external {
        require(msg.sender == governance, "!governance");
        require(_slippage <= 1000, ">10%");
        slippage[_token] = _slippage;
    }

    function convertSlippage(address _input, address _output) external override view  returns (uint) {
        uint _is = slippage[_input];
        uint _os = slippage[_output];
        return (_is > _os) ? _is : _os;
    }

    /**
     * This function allows governance to take unsupported tokens out of the contract. This is in an effort to make someone whole, should they seriously mess up.
     * There is no guarantee governance will vote to return these. It also allows for removal of airdropped tokens.
     */
    function governanceRecoverUnsupported(IERC20 _token, uint256 amount, address to) external {
        require(msg.sender == governance, "!governance");
        _token.transfer(to, amount);
    }
}