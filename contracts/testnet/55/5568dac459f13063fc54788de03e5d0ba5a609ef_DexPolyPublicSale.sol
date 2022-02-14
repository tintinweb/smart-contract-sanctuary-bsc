// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./IERC20.sol";
import "./Ownable.sol";
import "./Pausable.sol";

contract DexPolyPublicSale is Ownable, Pausable {
    IERC20 token; 
    uint256 public paymentPeriod = 0;
    uint256 private _coefficient = 500;
    uint256 private _fee = 3000000000000000; // 0.003 BNB;
    uint256 private _percent = 10;
    uint256 private _solded_percent = 15;
    uint256[] public REFERRAL_PERCENTS = [10, 5];
    uint256 constant public PERCENTS_DIVIDER = 100;

    struct UserInfo {
        uint256 investment;
        uint256 withdrawn;
        uint256 period;
        address referred;
    }

    mapping(address => uint256) public refincome;
    mapping(address => UserInfo) public userInfo;

    fallback() external payable {
        deposit(address(0x0));
    }

    receive() external payable {
        deposit(address(0x0));
    }

    function Setup(address token_addr) external returns (address) {
        token = IERC20(token_addr);
        return token_addr;
    }

    function deposit(address _referred) public payable whenNotPaused {
        UserInfo storage user = userInfo[msg.sender];

        uint256 _sold = msg.value * _coefficient;
        uint256 _payment = (_sold * _percent) / 100;

        require(
            token.balanceOf(address(this)) >= _payment,
            "INSUFFICIENT CONTRACT BALANCE"
        );

        if (
            _referred != address(0x0) &&
            _referred != msg.sender &&
            user.referred == address(0x0)
        ) {
            user.referred = _referred;
        }

        if (user.referred != address(0x0)) {
            address upline = user.referred;
			for (uint256 i = 0; i < 2; i++) {
				if (upline != address(0)) {
					uint256 amount = (msg.value * REFERRAL_PERCENTS[i]) / PERCENTS_DIVIDER;

					refincome[upline] += amount;


					upline = userInfo[upline].referred;
				} else break;
			}
        }

        require(token.transfer(msg.sender, _payment), "TRANSFER FAILED");

        user.investment += _sold;
        user.withdrawn += _payment;
        user.period = paymentPeriod;
    }

    function withdraw() external payable {
        UserInfo storage user = userInfo[msg.sender];
        uint256 _payment = available();
        require(_payment > 0, "WAIT FOR LAST PERIOD");
        require(token.transfer(msg.sender, _payment), "TRANSFER FAILED");
        user.withdrawn += _payment;
        user.period = paymentPeriod;
    }

    function withdrawRefincome() external payable {
        require(msg.value >= _fee, "INSUFFICIENT FEE");
        require(refincome[msg.sender] > 0, "YOU HAVE NOT REFINCOME");
        
        payable(msg.sender).transfer(refincome[msg.sender]);

        refincome[msg.sender] = 0;
    } 

    function available() public view returns (uint256) {
        UserInfo storage user = userInfo[msg.sender];
        uint256 _passPeriod = paymentPeriod - user.period;
        if (_passPeriod > 0) { 
            return (user.investment * (_passPeriod * _solded_percent)) / 100;
        } else {
            return 0;
        }
    }

    // Helpers
    function setCoefficient(uint256 coefficient)
        external
        onlyOwner
        returns (bool)
    {
        _coefficient = coefficient;
        return true;
    }

    function setPeriod(uint256 period) external onlyOwner returns (bool) {
        paymentPeriod = period;
        return true;
    }

    function withdrawToken(uint256 _amount) external onlyOwner returns (bool) {
        require(token.transfer(owner(), _amount), "TRANSFER FAILED");
        return true;
    }

    function withdrawBnb() external onlyOwner returns (bool) {
        if (address(this).balance >= 0) {
            payable(owner()).transfer(address(this).balance);
        }
        return true;
    }
}