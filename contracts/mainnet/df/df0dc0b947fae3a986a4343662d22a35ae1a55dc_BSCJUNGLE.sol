/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

// SPDX-License-Identifier: MIT

/*   BSCJUNGLE BUSD - is the new yield farm on Binance Smart Chain with a fixed and steady daily BUSD income
 *
 *   ┌───────────────────────────────────────────────────────────────────────┐
 *   │   Website: https://busd.bscjungle.com                                 │
 *   └───────────────────────────────────────────────────────────────────────┘
 *
 *   [INVESTMENT CONDITIONS]
 *
 *   - Minimal deposit: 5 BUSD, no maximal limit
 *   - Total income: from 40 days 140% to 70 days 230% (3% ROI increase for every day)
 *   - Earnings every second, withdraw any time
 *
 *   [AFFILIATE PROGRAM]
 *
 *   - 5-level referral reward: 4% - 2% - 1% - 0.5% - 0.5%
 *
 *   [FUNDS DISTRIBUTION]
 *
 *   - 82%: platform main balance, using for participants payouts, affiliate program bonuses
 *   -  5%: advertising and promotion expenses,
 *   -  5%: support work, technical functioning, administration fee
 *   -  8%: referrals
 *
 *   Note: This project is a high risk high profit dapp.
 *   Once contract balance drops to zero payments will stop,
 *   deposit at your own risk. DYOR.
 */

pragma solidity 0.8.14;

struct Tarif {
  uint8 life_days;
  uint16 percent;
}
struct Deposit {
  uint8 tarif;
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
  uint256[5] structure;
}
contract BSCJUNGLE {
    using SafeERC20 for IERC20;

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public match_bonus;
    
	uint8[] private REF_BONUSES = [40, 20, 10, 5, 5]; 
	uint256 private BONUS_LINES_COUNT = REF_BONUSES.length;
	uint8 private MRK_FEE = 50;
	uint8 private DEV_FEE = 50;
    uint8 private TARIF_MIN_DAYS = 40;
    uint8 private TARIF_MAX_DAYS = 70;
    uint8 private TARIF_PERC_INCREASE = 3;
    uint16 private TARIF_STARTING_ROI = 140;

	uint256 public MINIMUM_DEPOSIT;
	uint256 public MAXIMUM_DEPOSIT;
    IERC20 public tokenCAddress;

    bool public useNativeCoin = true;
    bool public isLaunched = false;

    mapping(uint8 => Tarif) private tarifs;
    mapping(address => Player) private players;
	address private contractOwner;
	address payable private markWallet;
	address payable private devWallet;

    event NewDeposit(address indexed addr, uint256 amount, uint16 tarif);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);

    constructor(
        address _tokenCAddr, 
        address payable _devAddr, 
        address payable _markAddr,
        uint256 _min_deposit,
        uint256 _max_deposit
    ) {
        contractOwner = msg.sender;

        if (_tokenCAddr != 0x0000000000000000000000000000000000000000) {
            tokenCAddress = IERC20(_tokenCAddr);
            useNativeCoin = false;
        }

        devWallet = _devAddr;
        markWallet = _markAddr;

        uint16 tarifPercent = TARIF_STARTING_ROI;
        for (uint8 tarifDuration = TARIF_MIN_DAYS; tarifDuration <= TARIF_MAX_DAYS; tarifDuration++) {
            tarifs[tarifDuration] = Tarif(tarifDuration, tarifPercent);
            tarifPercent += TARIF_PERC_INCREASE;
        }

        MINIMUM_DEPOSIT = _min_deposit;
        MAXIMUM_DEPOSIT = _max_deposit;
    }
    function _deposit(address _investor, uint8 _tarif, address _upline, uint256 amount) private {
        require(isLaunched, "Contract is not launched yet");
        require(_tarif >= TARIF_MIN_DAYS && _tarif <= TARIF_MAX_DAYS && amount > 0, "Invalid parameters");
        require(MINIMUM_DEPOSIT == 0 || amount >= MINIMUM_DEPOSIT, "Deposit is less than min");
        require(MAXIMUM_DEPOSIT == 0 || amount <= MAXIMUM_DEPOSIT, "Deposit is more than max");

        Player storage player = players[_investor];
        require(player.deposits.length < 100, "Max 100 deposits per address");

        uint256 mFee = amount * MRK_FEE / 1000;
		uint256 dFee = amount * DEV_FEE / 1000;

        if (useNativeCoin) {
            payable(markWallet).transfer(mFee);
            payable(devWallet).transfer(dFee);
        } else {
            //should transfer tokens if not using native coin 
            tokenCAddress.safeTransferFrom(_investor, address(this), amount);
            tokenCAddress.safeTransfer(markWallet, mFee);
            tokenCAddress.safeTransfer(devWallet, dFee);
        }

        _setUpline(_investor, _upline);

        player.deposits.push(Deposit({
            tarif: _tarif,
            amount: amount,
            time: uint40(block.timestamp)
        }));

        player.total_invested += amount;
        invested += amount;

        _refPayout(_investor, amount);
        
        emit NewDeposit(_investor, amount, _tarif);

    }
    function launch() external {
        require(msg.sender == contractOwner, "Owner only");
        isLaunched = true;
    }
    function deposit(uint8 _tarif, address _upline, uint256 amount) external {
        require(!useNativeCoin, "Contract uses native coin");
        _deposit(msg.sender, _tarif, _upline, amount);
    }
    function depositCoin(uint8 _tarif, address _upline) external payable {
        require(useNativeCoin, "Contract uses token");
        _deposit(msg.sender, _tarif, _upline, msg.value);
    }
    function _withdraw(address investor, uint256 amount) private {
        Player storage player = players[investor];
        _payout(investor);

        uint256 maxAmount = player.dividends + player.match_bonus;
        require(maxAmount > 0, "No dividends");
        
        uint256 contractBalance = useNativeCoin ? address(this).balance : tokenCAddress.balanceOf(address(this));
        require(contractBalance > 0, "Zero balance");

		if (maxAmount > contractBalance) {
            maxAmount = contractBalance;
        }

        if (amount == 0 || amount > maxAmount) {
            amount = maxAmount; //withdraw all available
        }

        withdrawn += amount;
        player.total_withdrawn += amount;

        if (amount == player.dividends + player.match_bonus) {
            player.match_bonus = 0;
            player.dividends = 0;
        } else if (amount <= player.match_bonus) {
            player.match_bonus -= amount;
        } else {
            player.dividends -= amount - player.match_bonus;
            player.match_bonus = 0;
        }
        
        if (useNativeCoin) {
            payable(investor).transfer(amount);
        } else {
            tokenCAddress.safeTransfer(investor, amount);
        }

        emit Withdraw(investor, amount);
    }
    function withdraw() external {
        _withdraw(msg.sender, 0);
    }
    function withdrawPartial(uint256 amount) external {
        _withdraw(msg.sender, amount);
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
        for (uint8 i = 0; i < BONUS_LINES_COUNT && address(0) != up; i++) {
            uint256 bonus = _amount * REF_BONUSES[i] / 1000;
            players[up].match_bonus += bonus;
            players[up].total_match_bonus += bonus;
            match_bonus += bonus;
            emit MatchPayout(up, _addr, bonus);
            up = players[up].upline;
        }
    }
    function _setUpline(address _addr, address _upline) private {
        players[_addr].upline = 0 < players[_upline].deposits.length ? _upline : devWallet;
        address up = players[_addr].upline;
        for (uint8 i = 0; i < BONUS_LINES_COUNT && address(0) != up; i++) {
            players[up].structure[i]++;
            up = players[up].upline;
        }
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
                value += (to - from) * dep.amount * tarif.percent / tarif.life_days / 8640000;
            }
        }
        return value;
    }
    function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256[5] memory structure) {
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