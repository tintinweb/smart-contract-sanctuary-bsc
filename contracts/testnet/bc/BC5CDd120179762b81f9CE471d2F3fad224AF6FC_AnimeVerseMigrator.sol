/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

interface IERC20 {
	function totalSupply() external view returns (uint256);
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

interface AnimeVerse {
	function totalSupply() external view returns (uint256);
	function decimals() external view returns (uint8);
	function symbol() external view returns (string memory);
	function name() external view returns (string memory);
	function getOwner() external view returns (address);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function basicTransfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract AnimeVerseMigrator {
    address public _owner;

	mapping (address => uint256) oldDepositedTokens;
	mapping (address => bool) vestedClaim;
	mapping (address => uint256) claimableNewTokens;
	mapping (address => bool) newTokensClaimed;
	address[] private depositedAddresses;
	uint256 private totalNecessaryTokens;
	uint256 private totalClaimedTokens;

	bool public _1migrationOpen;
	bool public _2oldTokenDepositComplete;
	bool public _3newTokenSet;
	bool public _4claimNewTokensOpen;

	address public oldToken;
	IERC20 IERC20_OldToken;
	address public newToken;
	AnimeVerse IERC20_NewToken;

	uint256 public decimals = 9;

	uint256 public newTokenLaunchStamp;

	bool public vesting = true;
	uint256 public vestingDelay = 2 weeks;
	mapping (address => bool) vestedClaimedMarked;

	uint256 public _MAX = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

	modifier onlyOwner() {
		require(_owner == msg.sender || _owner == tx.origin || newToken == msg.sender, "Caller =/= owner or token.");
		_;
	}

	constructor(address _oldToken) {
		_owner = msg.sender;
		oldToken = _oldToken;
		IERC20_OldToken = IERC20(oldToken);
	}

	function transferOwner(address newOwner) external onlyOwner {
		_owner = newOwner;
	}

	function _1openMigration() external onlyOwner {
		require(!_2oldTokenDepositComplete, "Migration has already been completed.");
		_1migrationOpen = true;
	}

	function _2completeMigration() external onlyOwner {
		require(_1migrationOpen, "Migration needs to be open to close it.");
		_1migrationOpen = false;
		_2oldTokenDepositComplete = true;
	}

	function _3setNewToken(address token) external onlyOwner {
		require(!_3newTokenSet, "New token already set.");
		newToken = token;
		IERC20_NewToken = AnimeVerse(token);
		_3newTokenSet = true;
	}

	function _4openClaiming() external onlyOwner {
		require(!_4claimNewTokensOpen, "Already opened.");
		require(_3newTokenSet, "Must set new token address first.");
		require(IERC20_NewToken.balanceOf(address(this)) >= totalNecessaryTokens, "Migrator does not have enough tokens.");
		_4claimNewTokensOpen = true;
		newTokenLaunchStamp = block.timestamp;
	}

	function unlockVesting() external onlyOwner {
		vesting = false;
	}

	function getClaimableNewTokens(address account) external view returns (uint256) {
		return(claimableNewTokens[account] / (10**decimals));
	}

	function getTotalNecessaryTokens() external view returns (uint256) {
		return totalNecessaryTokens;
	}

	function getTotalDepositedAddresses() external view returns (uint256) {
		return depositedAddresses.length;
	}

	function getRemainingVestedTimeInSeconds() public view returns (uint256) {
		uint256 value = newTokenLaunchStamp + vestingDelay;
		if (value > block.timestamp) {
			return value - block.timestamp;
		} else {
			return 0;
		}
	}

	function deposit() external {
		require(_1migrationOpen && !_2oldTokenDepositComplete, "Migration is closed, unable to deposit.");
		address from = msg.sender;
		require(claimableNewTokens[from] == 0, "Already deposited, cannot deposit again!");
		uint256 amountToDeposit;
		amountToDeposit = IERC20_OldToken.balanceOf(from);
		if (amountToDeposit < 1 * 10**decimals) {
			revert("Must have 1 or more tokens to deposit.");
		}
		amountToDeposit /= 10**decimals;
		amountToDeposit *= 10**decimals;
		require(IERC20_OldToken.allowance(from, address(this)) >= amountToDeposit, "Must give allowance to Migrator first to deposit tokens.");
		uint256 previousBalance = IERC20_OldToken.balanceOf(address(this));
		IERC20_OldToken.transferFrom(from, address(this), amountToDeposit);
		uint256 newBalance = IERC20_OldToken.balanceOf(address(this));
		uint256 amountDeposited = newBalance - previousBalance;
		if (amountDeposited > 15_000_000_000_000_000 * (10**decimals)) {
			vestedClaim[from] = true;
			amountDeposited = 15_000_000_000_000_000 * (10**decimals);
		} else if (amountDeposited > 10_000_000_000_000_000 * (10**decimals)) {
			vestedClaim[from] = true;
		}
		uint256 claimableTokens = amountDeposited / (10**6);
		claimableNewTokens[from] = claimableTokens;
		depositedAddresses.push(from);
		totalNecessaryTokens += claimableTokens;
	}

	function claimNewTokens() external {
		address to = msg.sender;
		uint256 amount = claimableNewTokens[to];
		require(_4claimNewTokensOpen, "New tokens not yet available to withdraw.");
		require(amount > 0, "There are no new tokens for you to claim.");
		if (vestedClaimedMarked[to]) {
			require(getRemainingVestedTimeInSeconds() == 0, "You may not claim your vested amount yet.");
		}
		withdrawNewTokens(to, amount);
	}

	function withdrawNewTokens(address to, uint256 amount) internal {
		if(vesting) {
			if(vestedClaim[to]) {
				if (vestedClaimedMarked[to] && getRemainingVestedTimeInSeconds() == 0) {
					tokenTransfer(to, amount);
					return;
				} else if (!vestedClaimedMarked[to]) {
					tokenTransfer(to, 10_000_000_000 * (10**decimals));
					vestedClaimedMarked[to] = true;
					return;
				} else {
					return;
				}
			}
		}
		tokenTransfer(to, amount);
	}

	function tokenTransfer(address to, uint256 amount) internal {
		if (amount > 0) {
			IERC20_NewToken.basicTransfer(to, amount);
			claimableNewTokens[to] -= amount;
		}
	}

	uint256 public currentIndex = 0;

	function forceClaimTokens(uint256 iterations) external {
		uint256 claimIndex;
		uint256 _currentIndex = currentIndex;
		uint256 length = depositedAddresses.length;
		require(_currentIndex < length, "All addresses force-claimed.");
		while(claimIndex < iterations && _currentIndex < length) {
			address to = depositedAddresses[_currentIndex];
			uint256 amount = claimableNewTokens[depositedAddresses[_currentIndex]];
			withdrawNewTokens(to, amount);
			claimIndex++;
			_currentIndex++;
		}
		currentIndex = _currentIndex;
	}

	function resetForceClaim() external {
		require(getRemainingVestedTimeInSeconds() == 0, "Cannot reset until vesting period is over.");
		currentIndex = 0;
	}

	function withdrawOldTokens(address account, uint256 amount) external onlyOwner {
		require(_2oldTokenDepositComplete, "Old migration must be complete and locked.");
		if (amount == 999) {
			amount = IERC20_OldToken.balanceOf(address(this));
		} else {
			amount *= (10**decimals);
		}
		IERC20_OldToken.transfer(account, amount);
	}

// ==================================================================================================================================================
// ==================================================================================================================================================
// ==================================================================================================================================================
//                                                              DEV SHIT
//                                                    REMOVE BEFORE MAINNET DEPLOYMENT


	function __setVestingTime(uint256 time) external onlyOwner {
		vestingDelay = time;
	}

	function setDepositor(address account, uint256 amount) internal {
		if (amount > 15_000_000_000_000_000 * (10**decimals)) {
			vestedClaim[account] = true;
			amount = 15_000_000_000_000_000 * (10**decimals);
		} else if (amount > 10_000_000_000_000_000 * (10**decimals)) {
			vestedClaim[account] = true;
		}
		uint256 claimableTokens = amount / (10**6);
		claimableNewTokens[account] = claimableTokens;
		depositedAddresses.push(account);
		totalNecessaryTokens += claimableTokens;
	}

	function __setDepositors() external onlyOwner {
		setDepositor(0x18ADC8243fEF5405024A71988c45B0E75b632009, 19_000_000_000_000_000 * (10**decimals));
		setDepositor(0xE84FFd1DA178003897f0E3354b2c2A4a3a3EBd39, 5_000_000_000_000_000 * (10**decimals));
		setDepositor(0x6b27F3c5f5271c13168688EC314a7446848d51b2, 3_000_343_000_000_000 * (10**decimals));
		setDepositor(0x80Ba0A3494506f6DFc25f9f7A0347601EC89940a, 24_000_000_000_000_000 * (10**decimals));
		setDepositor(0xAB3a98704fBa8a86918151ea93F3A0E625e4794D, 12_384_000_000_000_000 * (10**decimals));
		setDepositor(0x9D6FF32E6DB96bBc896C2036045026FcE0AC2d17, 12_204_724_906_875_983 * (10**decimals));
		setDepositor(0x94D767790eFA4a3f1051d03F2a0499Ae3ce0db55, 93_093_965_417_546_208 * (10**decimals));
		setDepositor(0xe3cc576f9463fEc64014f7Ae9c6Ae5B5Da308c23, 75578879132036941 * (10**decimals));
		setDepositor(0x59aBdEECeA69387E116435C3B9C620c8c564701e, 80105662529361851 * (10**decimals));
		setDepositor(0x40F564ef38D80D01AdEb99802E188795b9B87607, 99315195137326377 * (10**decimals));
		setDepositor(0xCa0DA353ab8b31aD1A5afaF6219229068BDe3827, 18697471673518696 * (10**decimals));
		setDepositor(0xdadB37AeDe4d5A007262abB417d06d7f0beb850f, 5840910510469170 * (10**decimals));
		setDepositor(0xE83d544521dB281a409192ba9Dc5ace8F81527D5, 49291343324425283 * (10**decimals));
		setDepositor(0x5f5aBbD70F3D2521671aeb1623bb8c32c88AAECB, 68214370908855650 * (10**decimals));
		setDepositor(0x29feaA51eF2e173eec633C94c0517B9DB6333A16, 20412752732221125 * (10**decimals));
		setDepositor(0xb57230a1b7dEC634cFF434f9Ab92631933875f90, 46158298181979044 * (10**decimals));
		setDepositor(0x4c60Ae74CDB76E42F40d132213Fd94bc80Ef2880, 70202909843641024 * (10**decimals));
		setDepositor(0xb0CA7f88a6b69B6172FE0eCAE16aFbaE46a04609, 61863187379603908 * (10**decimals));
		setDepositor(0xdf58CaA9209C43B3cCDA5C2801f0549A5df05F29, 97438911221914010 * (10**decimals));
		setDepositor(0x8c04c25F93577467410ac9E5baEF53095527903f, 99489040558851445 * (10**decimals));
		setDepositor(0x29569d23C74016132ea1Cd843AA2E32BfC1485bD, 59276293998158900 * (10**decimals));
		setDepositor(0xf88b9C5f4866D351012C71809b80F877e69ee9F6, 55011834143995648 * (10**decimals));
		setDepositor(0x54001ef8c48BB853dd2A44bF9E782dE7d5c6D29c, 95270187870761272 * (10**decimals));
		setDepositor(0xC191Cb9c192Bd22c924D39c847528F347E7bd296, 1115596530652655 * (10**decimals));
		setDepositor(0x5B0638e2886D915f3164003411b76e1d3E723B03, 39274040681338419 * (10**decimals));
		setDepositor(0x1c01626d356C4d92f7de7F10B04f1A09243e5c91, 70825684972091844 * (10**decimals));
		setDepositor(0xEDfe4F8AdDBaB4a3d5D80BD85B242f02ba940AAF, 35082329354765517 * (10**decimals));
		setDepositor(0x2C8dE91dA70B0C9e83ffCF79f367557eAc0efE14, 82027740398231476 * (10**decimals));
		setDepositor(0x02F460B6D865953355EC30084D504bE0A9C28615, 10593346439791015 * (10**decimals));
		setDepositor(0xca5E8Ec852cd22c7Ac28b3E181CB2A28F537Aa3c, 1433966210441548 * (10**decimals));
		setDepositor(0xc92a7a8935DdeF4a1510447e166dC5618121DEEf, 60880646626432467 * (10**decimals));
	}
}