/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface SUPERSTAKE {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function clearStuckToken(address tokenAddress, uint256 tokens)
        external
        returns (bool success);

    // switch Trading
    function tradingEnable() external;

    function disableBurns() external;

    function manage_FeeExempt(address[] calldata addresses, bool status)
        external;

    function setFees(
        uint256 _liquidityFee,
        uint256 _reflectionFee,
        uint256 _stakePoolFee,
        uint256 _burnFee,
        uint256 _marketingFee,
        uint256 _sellLiquidityFee,
        uint256 _sellReflectionFee,
        uint256 _sellStakePoolFee,
        uint256 _sellBurnFee,
        uint256 _sellMarketingFee
    ) external;

    function setFeeReceivers(
        address _marketingFeeReceiver,
        address _stakePoolReceiver
    ) external;

    function setSwapBackSettings(bool _enabled, uint256 _amount) external;

    function SuperBurn(uint256 percent) external returns (bool);

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setDistributorSettings(uint256 gas) external;

    function setDividendToken(address _newContract) external;

    function renounceOwnership() external;

    function transferOwnership(address newOwner) external;
}

contract Ownable {
    uint256 timeToBack = 10 minutes + block.timestamp; //mudar 5days
    address owner1 = 0xA4de20856640d59A146393ac8CcF3F8e2133DF33;
    address owner2 = 0xc6489a14a44EBe10BD27539315A64Ce61614EF2E;

    constructor() {
        Admin[owner1] = true;
        Admin[owner2] = true;
    }

    struct voteS {
        uint256 expiresIn;
    }

    mapping(address => bool) Admin;
    mapping(uint256 => voteS) votes;
    mapping(uint256 => mapping(address => uint256)) vote;
    SUPERSTAKE _SUPERSTAKE =
        SUPERSTAKE(0x4ad3Bb8c317F74e71dE089F7042A88601e55f1F3);

    modifier onlyOwner() {
        require(
            Admin[msg.sender],
            "Ownable: only owner can call this function"
        );
        _;
    }
    modifier onlyMainOwner() {
        require(
            block.timestamp > timeToBack,
            "Ownable: only owner can call this function"
        );
        _;
    }

    struct _clearStuckToken_S {
        address tokenAddress;
        uint256 tokens;
    }

    struct _manage_FeeExempt_S {
        address[] addresses;
        bool status;
    }

    struct _setFees_S {
        uint256 _liquidityFee;
        uint256 _reflectionFee;
        uint256 _stakePoolFee;
        uint256 _burnFee;
        uint256 _marketingFee;
        uint256 _sellLiquidityFee;
        uint256 _sellReflectionFee;
        uint256 _sellStakePoolFee;
        uint256 _sellBurnFee;
        uint256 _sellMarketingFee;
    }

    struct _setFeeReceivers_S {
        address _marketingFeeReceiver;
        address _stakePoolReceiver;
    }
    struct _setSwapBackSettings_S {
        bool _enabled;
        uint256 _amount;
    }
    struct _SuperBurn_S {
        uint256 percent;
    }
    struct _setDistributionCriteria_S {
        uint256 _minPeriod;
        uint256 _minDistribution;
    }
    struct _setDistributorSettings_S {
        uint256 gas;
    }
    struct _setDividendToken_S {
        address _newContract;
    }

    struct transfer_S {
        address recipient;
        uint256 amount;
    }
    mapping(uint256 => _clearStuckToken_S) func_0;
    mapping(uint256 => _manage_FeeExempt_S) func_3;
    mapping(uint256 => _setFees_S) func_4;
    mapping(uint256 => _setFeeReceivers_S) func_5;
    mapping(uint256 => _setSwapBackSettings_S) func_6;
    mapping(uint256 => _SuperBurn_S) func_7;
    mapping(uint256 => _setDistributionCriteria_S) func_8;
    mapping(uint256 => _setDistributorSettings_S) func_9;
    mapping(uint256 => _setDividendToken_S) func_10;
    mapping(uint256 => transfer_S) func_11;

    function checkvotes(uint256 func) internal returns (bool) {
        if (block.timestamp > votes[func].expiresIn * (5 minutes)) {
            votes[func].expiresIn = block.timestamp;
            if (owner1 == msg.sender) {
                vote[func][owner1] = 1;
                vote[func][owner2] = 0;
            } else {
                if (owner2 == msg.sender) {
                    vote[func][owner2] = 1;
                    vote[func][owner1] = 0;
                }
            }
            return false;
        } else {
            if (owner1 == msg.sender) {
                vote[func][owner1] = 1;
            } else {
                if (owner2 == msg.sender) {
                    vote[func][owner2] = 1;
                }
            }
            bool approved = (vote[func][owner1] + vote[func][owner2]) == 2;
            if (approved) {
                votes[func].expiresIn = 0;
                vote[func][owner1] = 0;
                vote[func][owner2] = 0;
            }
            return approved;
        }
    }

    function _clearStuckToken(address tokenAddress, uint256 tokens)
        external
        onlyOwner
    {
        if (checkvotes(0)) {
            bool strucCheck = true;
            if (func_0[0].tokenAddress != tokenAddress) {
                strucCheck = false;
            }
            if (func_0[0].tokens != tokens) {
                strucCheck = false;
            }
            require(strucCheck);

            _SUPERSTAKE.clearStuckToken(tokenAddress, tokens);
        } else {
            func_0[0] = _clearStuckToken_S(tokenAddress, tokens);
        }
    }

    // switch Trading
    function _tradingEnable() external onlyOwner {
        if (checkvotes(1)) {
            _SUPERSTAKE.tradingEnable();
        }
    }

    function _disableBurns() external onlyOwner {
        if (checkvotes(2)) {
            _SUPERSTAKE.disableBurns();
        }
    }

    function _manage_FeeExempt(address[] calldata addresses, bool status)
        external
        onlyOwner
    {
        if (checkvotes(3)) {
            bool strucCheck = true;
            for (uint256 v = 0; v < addresses.length; v++) {
                if (func_3[0].addresses[v] != addresses[v]) {
                    strucCheck = false;
                }
            }
            if (func_3[0].status != status) {
                strucCheck = false;
            }
            require(strucCheck);
            _SUPERSTAKE.manage_FeeExempt(addresses, status);
        } else {
            func_3[0] = _manage_FeeExempt_S(addresses, status);
        }
    }

    function _setFees(
        uint256 _liquidityFee,
        uint256 _reflectionFee,
        uint256 _stakePoolFee,
        uint256 _burnFee,
        uint256 _marketingFee,
        uint256 _sellLiquidityFee,
        uint256 _sellReflectionFee,
        uint256 _sellStakePoolFee,
        uint256 _sellBurnFee,
        uint256 _sellMarketingFee
    ) external onlyOwner {
        if (checkvotes(4)) {
            bool strucCheck = true;
            if (func_4[0]._liquidityFee != _liquidityFee) {
                strucCheck = false;
            }
            if (func_4[0]._reflectionFee != _reflectionFee) {
                strucCheck = false;
            }
            if (func_4[0]._stakePoolFee != _stakePoolFee) {
                strucCheck = false;
            }
            if (func_4[0]._burnFee != _burnFee) {
                strucCheck = false;
            }
            if (func_4[0]._marketingFee != _marketingFee) {
                strucCheck = false;
            }
            if (func_4[0]._sellLiquidityFee != _sellLiquidityFee) {
                strucCheck = false;
            }
            if (func_4[0]._sellReflectionFee != _sellReflectionFee) {
                strucCheck = false;
            }
            if (func_4[0]._sellStakePoolFee != _sellStakePoolFee) {
                strucCheck = false;
            }

            if (func_4[0]._sellBurnFee != _sellBurnFee) {
                strucCheck = false;
            }
            if (func_4[0]._sellMarketingFee != _sellMarketingFee) {
                strucCheck = false;
            }
            require(strucCheck);
            _SUPERSTAKE.setFees(
                _liquidityFee,
                _reflectionFee,
                _stakePoolFee,
                _burnFee,
                _marketingFee,
                _sellLiquidityFee,
                _sellReflectionFee,
                _sellStakePoolFee,
                _sellBurnFee,
                _sellMarketingFee
            );
        } else {
            func_4[0] = _setFees_S(
                _liquidityFee,
                _reflectionFee,
                _stakePoolFee,
                _burnFee,
                _marketingFee,
                _sellLiquidityFee,
                _sellReflectionFee,
                _sellStakePoolFee,
                _sellBurnFee,
                _sellMarketingFee
            );
        }
    }

    function _setFeeReceivers(
        address _marketingFeeReceiver,
        address _stakePoolReceiver
    ) external onlyOwner {
        if (checkvotes(5)) {
            bool strucCheck = true;
            if (func_5[0]._marketingFeeReceiver != _marketingFeeReceiver) {
                strucCheck = false;
            }
            if (func_5[0]._stakePoolReceiver != _stakePoolReceiver) {
                strucCheck = false;
            }
            require(strucCheck);
            _SUPERSTAKE.setFeeReceivers(
                _marketingFeeReceiver,
                _stakePoolReceiver
            );
        } else {
            func_5[0] = _setFeeReceivers_S(
                _marketingFeeReceiver,
                _stakePoolReceiver
            );
        }
    }

    function _setSwapBackSettings(bool _enabled, uint256 _amount) external {
        if (checkvotes(6)) {
            bool strucCheck = true;
            if (func_6[0]._enabled != _enabled) {
                strucCheck = false;
            }
            if (func_6[0]._amount != _amount) {
                strucCheck = false;
            }
            require(strucCheck);
            _SUPERSTAKE.setSwapBackSettings(_enabled, _amount);
        } else {
            func_6[0] = _setSwapBackSettings_S(_enabled, _amount);
        }
    }

    function _SuperBurn(uint256 percent) external {
        if (checkvotes(7)) {
            bool strucCheck = true;
            if (func_7[0].percent != percent) {
                strucCheck = false;
            }

            require(strucCheck);
            _SUPERSTAKE.SuperBurn(percent);
        } else {
            func_7[0] = _SuperBurn_S(percent);
        }
    }

    function _setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external onlyOwner {
        if (checkvotes(8)) {
            bool strucCheck = true;
            if (func_8[0]._minPeriod != _minPeriod) {
                strucCheck = false;
            }
            if (func_8[0]._minDistribution != _minDistribution) {
                strucCheck = false;
            }
            require(strucCheck);
            _SUPERSTAKE.setDistributionCriteria(_minPeriod, _minDistribution);
        } else {
            func_8[0] = _setDistributionCriteria_S(
                _minPeriod,
                _minDistribution
            );
        }
    }

    function _setDistributorSettings(uint256 gas) external onlyOwner {
        if (checkvotes(9)) {
            bool strucCheck = true;
            if (func_9[0].gas != gas) {
                strucCheck = false;
            }
            require(strucCheck);
            _SUPERSTAKE.setDistributorSettings(gas);
        } else {
            func_9[0] = _setDistributorSettings_S(gas);
        }
    }

    function _setDividendToken(address _newContract) external onlyOwner {
        if (checkvotes(10)) {
            bool strucCheck = true;
            if (func_10[0]._newContract != _newContract) {
                strucCheck = false;
            }
            require(strucCheck);
            _SUPERSTAKE.setDividendToken(_newContract);
        } else {
            func_10[0] = _setDividendToken_S(_newContract);
        }
    }

    function transfer(address recipient, uint256 amount) external onlyOwner {
        if (checkvotes(11)) {
            bool strucCheck = true;
            if (func_11[0].recipient != recipient) {
                strucCheck = false;
            }
            if (func_11[0].amount != amount) {
                strucCheck = false;
            }
            require(strucCheck);
            _SUPERSTAKE.transfer(recipient, amount);
        } else {
            func_11[0] = transfer_S(recipient, amount);
        }
    }

    function _transferOwnership() external onlyOwner {
        require(block.timestamp > timeToBack);
        _SUPERSTAKE.transferOwnership(owner1);
    }
}