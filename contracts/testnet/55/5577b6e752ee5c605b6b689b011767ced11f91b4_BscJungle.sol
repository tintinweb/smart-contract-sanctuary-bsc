/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

struct Tarif {
  uint16 life_days;
  uint16 percent;
}
struct Deposit {
  uint16 tarif;
  uint256 amount;
  uint40 time;
}
struct Player {
  address upline;
  uint256 dividends;
  uint256 match_bonus;
  uint40 last_payout;
  uint256 total_invested;
  uint256 total_withdrawn;
  uint256 total_match_bonus;
  Deposit[] deposits;
  uint256[100] structure;
}
contract BscJungle {
	using SafeMath for uint256;
    using SafeMath for uint40;
    using SafeERC20 for IERC20;

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public match_bonus;
    
    uint16 constant PERCENT_DIVIDER = 1000; 
    uint16 constant CAN_SET_MAX_REF_LEVELS = 100; 
    
	uint256 public BONUS_LINES_COUNT; // = 5;
	uint8[] public REF_BONUSES; // = [40, 20, 10, 5, 5]; 
	uint16 public MRK_FEE; // = 50;
	uint16 public DEV_FEE; // = 50;
    uint16 public TARIF_MIN_DAYS; // = 40;
    uint16 public TARIF_MAX_DAYS; // = 70;
    uint16 public TARIF_PERC_INCREASE; // = 3;
    uint16 public TARIF_STARTING_ROI; // = 140;
	uint256 public MINIMUM_DEPOSIT;    

    uint40 public LAUNCHED_AT = 0;
    IERC20 public tokenCAddress;
    bool public useNativeCoin = true;
    bool public isContractParamsSet = false;
    bool public isSealed = false;

	address public contractOwner;

    mapping(uint16 => Tarif) public tarifs;
    mapping(address => Player) private players;
    
	address payable private markWallet;
	address payable private devWallet;

    event NewDeposit(address indexed addr, uint256 amount, uint16 tarif);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);

    constructor() {
        contractOwner = msg.sender;
    }
    function launch() external {
        require(msg.sender == contractOwner, "Owner only");
        require(LAUNCHED_AT <= 0, "Contract has already been launched");
        require(isContractParamsSet, "Cannot launch before contract parameters have been set");

        LAUNCHED_AT = uint40(block.timestamp);
    }
    function seal() external {
        require(msg.sender == contractOwner, "Owner only");
        require(!isSealed, "Cannot seal twice");
        require(isContractParamsSet, "Contract parameters must be set before sealing"); // Owner can set contract parameters only once before the launch!
        
        isSealed = true;
    }
    function setContractParameters(
        address _tokenCAddr,
        uint256 _min_deposit,
        uint16 _tarif_min_days, 
        uint16 _tarif_max_days, 
        uint16 _tarif_perc_increase, 
        uint16 _tarif_starting_roi, 
	    uint16 _dev_fee,
        address payable _devAddr,
	    uint16 _mrk_fee,
        address payable _markAddr, 
        uint8[] memory _ref_bonuses
    ) external {
        require(msg.sender == contractOwner, "Owner only");
        require(!isSealed, "Cannot change parameters after contract is sealed");
        require(LAUNCHED_AT <= 0, "Contract has already been launched");


        require(_tarif_min_days > 0, "Invalid minimum days");
        require(_tarif_max_days >= _tarif_min_days, "Invalid maximum days");
        require(_tarif_perc_increase > 0, "Invalid percentage increase");
        require(_tarif_starting_roi >= 100, "Invalid starting roi");

        MINIMUM_DEPOSIT = _min_deposit;

        BONUS_LINES_COUNT = _ref_bonuses.length;
        require(BONUS_LINES_COUNT <= CAN_SET_MAX_REF_LEVELS, "Cannot set more than 100 ref levels");

        markWallet = _markAddr;
        devWallet = _devAddr;

        DEV_FEE = _dev_fee;
        MRK_FEE = _mrk_fee;
        REF_BONUSES = _ref_bonuses;

        TARIF_MIN_DAYS = _tarif_min_days;
        TARIF_MAX_DAYS = _tarif_max_days;
        TARIF_PERC_INCREASE = _tarif_perc_increase;
        TARIF_STARTING_ROI = _tarif_starting_roi;

        if (_tokenCAddr != 0x0000000000000000000000000000000000000000) {
            tokenCAddress = IERC20(_tokenCAddr);
            useNativeCoin = false;
        }
        uint16 tarifPercent = TARIF_STARTING_ROI;
        for (uint16 tarifDuration = TARIF_MIN_DAYS; tarifDuration <= TARIF_MAX_DAYS; tarifDuration++) {
            tarifs[tarifDuration] = Tarif(tarifDuration, tarifPercent);
            tarifPercent += TARIF_PERC_INCREASE;
        }
        isContractParamsSet = true;
    }
    function _payout(address _addr) private {
        uint256 payout = this.payoutOf(_addr);
        if (payout > 0) {
            players[_addr].last_payout = uint40(block.timestamp);
            players[_addr].dividends += payout;
        }
    }
    function _refPayout(address _addr, uint256 _amount) private {
        address up = players[_addr].upline;
        for (uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
            if (up == address(0)) break;
            uint256 bonus = _amount * REF_BONUSES[i] / PERCENT_DIVIDER;
            players[up].match_bonus += bonus;
            players[up].total_match_bonus += bonus;
            match_bonus += bonus;
            emit MatchPayout(up, _addr, bonus);
            up = players[up].upline;
        }
    }
    function _setUpline(address _addr, address _upline) private {
        if (players[_addr].upline == address(0) && _addr != markWallet) {
            if (players[_upline].deposits.length == 0) {
                _upline = markWallet;
            }
            players[_addr].upline = _upline;
            for (uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
                players[_upline].structure[i]++;
                _upline = players[_upline].upline;
                if (_upline == address(0)) break;
            }
        }
    }
    function deposit(uint16 _tarif, address _upline, uint256 _amount) external payable {
        require(_tarif >= TARIF_MIN_DAYS, "Tarif not found");
        require(_tarif <= TARIF_MAX_DAYS, "Tarif not found");
        require(LAUNCHED_AT > 0, "Contract is not launched yet");

        uint256 amount = useNativeCoin ? msg.value : _amount;
        //require(amount > 0, "Deposit amount cannot be 0");
        require(MINIMUM_DEPOSIT == 0 || amount >= MINIMUM_DEPOSIT, "Must deposit at least minimum amount");

        Player storage player = players[msg.sender];
        require(player.deposits.length < 100, "Max 100 deposits per address");

        uint256 mFee = amount.mul(MRK_FEE).div(PERCENT_DIVIDER);
		uint256 dFee = amount.mul(DEV_FEE).div(PERCENT_DIVIDER);

        if (useNativeCoin) {
            payable(markWallet).transfer(mFee);
            payable(devWallet).transfer(dFee);
        } else {
            tokenCAddress.safeTransferFrom(msg.sender, address(this), amount);
            tokenCAddress.safeTransfer(markWallet, mFee);
            tokenCAddress.safeTransfer(devWallet, dFee);
        }

        _setUpline(msg.sender, _upline);

        player.deposits.push(Deposit({
            tarif: _tarif,
            amount: amount,
            time: uint40(block.timestamp)
        }));

        player.total_invested += amount;
        invested += amount;

        _refPayout(msg.sender, amount);
        
        emit NewDeposit(msg.sender, amount, _tarif);
    }
    function withdraw() external {
        require(LAUNCHED_AT > 0, "Contract is not launched yet");

        Player storage player = players[msg.sender];
        _payout(msg.sender);

        uint256 amount = player.dividends + player.match_bonus;
        require(amount > 0, "Zero amount");

        player.dividends = 0;
        player.match_bonus = 0;
        player.total_withdrawn += amount;
        withdrawn += amount;

        if (useNativeCoin) {
            payable(msg.sender).transfer(amount);
        } else {
            tokenCAddress.safeTransfer(msg.sender, amount);
        }

        emit Withdraw(msg.sender, amount);
    }
    function payoutOf(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];

        for (uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint40 time_end = dep.time + tarif.life_days * 86400;
            uint40 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint40 to = block.timestamp > time_end ? time_end : uint40(block.timestamp);

            if (from < to) {
                value += dep.amount * (to.sub(from)) * tarif.percent / tarif.life_days / 8640000;
            }
        }

        return value;
    }
    function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256[] memory structure) {
        Player storage player = players[_addr];
        uint256 payout = this.payoutOf(_addr);
        for (uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
            structure[i] = player.structure[i];
        }
        return (
            payout + player.dividends + player.match_bonus,
            player.total_invested,
            player.total_withdrawn,
            player.total_match_bonus,
            structure
        );
    }
    function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _match_bonus) {
        return (invested, withdrawn, match_bonus);
    }
}

// libraries
interface IERC20 {
    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function transfer(address recipient, uint256 amount) external returns(bool);
    function allowance(address owner, address spender) external view returns(uint256);
    function approve(address spender, uint256 amount) external returns(bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns(bool);
        
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
    }
    
    library Address {
        function isContract(address account) internal view returns(bool) {
            uint256 size;
            assembly {
                size:= extcodesize(account)
            }
            return size > 0;
        }
        function sendValue(address payable recipient, uint256 amount) internal {
            require(address(this).balance >= amount, "Address: insufficient balance");
    
            (bool success, ) = recipient.call{ value: amount } ("");
            require(success, "Address: unable to send value, recipient may have reverted");
        }
        function functionCall(address target, bytes memory data) internal returns(bytes memory) {
            return functionCall(target, data, "Address: low-level call failed");
        }
        function functionCall(
            address target,
            bytes memory data,
            string memory errorMessage
        ) internal returns(bytes memory) {
            return functionCallWithValue(target, data, 0, errorMessage);
        }
        function functionCallWithValue(
            address target,
            bytes memory data,
            uint256 value
        ) internal returns(bytes memory) {
            return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
        }
        function functionCallWithValue(
            address target,
            bytes memory data,
            uint256 value,
            string memory errorMessage
        ) internal returns(bytes memory) {
            require(address(this).balance >= value, "Address: insufficient balance for call");
            require(isContract(target), "Address: call to non-contract");
    
            (bool success, bytes memory returndata) = target.call{ value: value } (data);
            return verifyCallResult(success, returndata, errorMessage);
        }
        function functionStaticCall(address target, bytes memory data) internal view returns(bytes memory) {
            return functionStaticCall(target, data, "Address: low-level static call failed");
        }
        function functionStaticCall(
            address target,
            bytes memory data,
            string memory errorMessage
        ) internal view returns(bytes memory) {
            require(isContract(target), "Address: static call to non-contract");
    
            (bool success, bytes memory returndata) = target.staticcall(data);
            return verifyCallResult(success, returndata, errorMessage);
        }
        function functionDelegateCall(address target, bytes memory data) internal returns(bytes memory) {
            return functionDelegateCall(target, data, "Address: low-level delegate call failed");
        }
        function functionDelegateCall(
            address target,
            bytes memory data,
            string memory errorMessage
        ) internal returns(bytes memory) {
            require(isContract(target), "Address: delegate call to non-contract");
    
            (bool success, bytes memory returndata) = target.delegatecall(data);
            return verifyCallResult(success, returndata, errorMessage);
        }
        function verifyCallResult(
            bool success,
            bytes memory returndata,
            string memory errorMessage
        ) internal pure returns(bytes memory) {
            if (success) {
                return returndata;
            } else {
    
                if (returndata.length > 0) {
                    
    
                    assembly {
                        let returndata_size:= mload(returndata)
                        revert(add(32, returndata), returndata_size)
                    }
                } else {
                    revert(errorMessage);
                }
            }
        }
    }
    
    library SafeERC20 {
        using Address for address;
    
        function safeTransfer(
                IERC20 token,
                address to,
                uint256 value
            ) internal {
            _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
        }
        function safeTransferFrom(
            IERC20 token,
            address from,
            address to,
            uint256 value
        ) internal {
            _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
        }
        function safeApprove(
            IERC20 token,
            address spender,
            uint256 value
        ) internal {
            require(
                (value == 0) || (token.allowance(address(this), spender) == 0),
                "SafeERC20: approve from non-zero to non-zero allowance"
            );
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
        }
        function safeIncreaseAllowance(
            IERC20 token,
            address spender,
            uint256 value
        ) internal {
            uint256 newAllowance = token.allowance(address(this), spender) + value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
        function safeDecreaseAllowance(
            IERC20 token,
            address spender,
            uint256 value
        ) internal {
            unchecked {
                uint256 oldAllowance = token.allowance(address(this), spender);
                require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
                uint256 newAllowance = oldAllowance - value;
                _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
            }
        }
        function _callOptionalReturn(IERC20 token, bytes memory data) private {
            bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
            if (returndata.length > 0) {
    
                require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
            }
        }
    }
    
    library SafeMath {
        function add(uint256 a, uint256 b) internal pure returns(uint256) {
            uint256 c = a + b;
            require(c >= a, "SafeMath: addition overflow");
    
            return c;
        }
        function sub(uint256 a, uint256 b) internal pure returns(uint256) {
            require(b <= a, "SafeMath: subtraction overflow");
            uint256 c = a - b;
    
            return c;
        }
        function mul(uint256 a, uint256 b) internal pure returns(uint256) {
            if (a == 0) {
                return 0;
            }
    
            uint256 c = a * b;
            require(c / a == b, "SafeMath: multiplication overflow");
    
            return c;
        }
        function div(uint256 a, uint256 b) internal pure returns(uint256) {
            require(b > 0, "SafeMath: division by zero");
            uint256 c = a / b;
    
            return c;
        }
    }