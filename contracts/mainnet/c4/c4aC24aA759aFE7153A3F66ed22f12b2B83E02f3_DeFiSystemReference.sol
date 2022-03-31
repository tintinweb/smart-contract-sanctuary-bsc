// SPDX-License-Identifier: MIT
/*
██████╗ ███████╗███████╗██╗    ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
██╔══██╗██╔════╝██╔════╝██║    ██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
██║  ██║█████╗  █████╗  ██║    ███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
██║  ██║██╔══╝  ██╔══╝  ██║    ╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
██████╔╝███████╗██║     ██║    ███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
╚═════╝ ╚══════╝╚═╝     ╚═╝    ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝

███████╗ ██████╗ ██████╗     ██████╗ ███████╗███████╗███████╗██████╗ ███████╗███╗   ██╗ ██████╗███████╗
██╔════╝██╔═══██╗██╔══██╗    ██╔══██╗██╔════╝██╔════╝██╔════╝██╔══██╗██╔════╝████╗  ██║██╔════╝██╔════╝
█████╗  ██║   ██║██████╔╝    ██████╔╝█████╗  █████╗  █████╗  ██████╔╝█████╗  ██╔██╗ ██║██║     █████╗
██╔══╝  ██║   ██║██╔══██╗    ██╔══██╗██╔══╝  ██╔══╝  ██╔══╝  ██╔══██╗██╔══╝  ██║╚██╗██║██║     ██╔══╝
██║     ╚██████╔╝██║  ██║    ██║  ██║███████╗██║     ███████╗██║  ██║███████╗██║ ╚████║╚██████╗███████╗
╚═╝      ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝╚══════╝
Developed by systemdefi.crypto and rsd.cash teams
---------------------------------------------------------------------------------------
DeFi System for Reference (DSR) is a multi-functional token that integrates the use of
automated financial managers to generate value for the token, for its holders, and
improve the system as a whole. The ecosystem triad now consists of RSD, SDR, and DSR.
Reference System for DeFi (RSD) is the utility token for the ecosystem with its dynamic
supply algorithm that can interact externally and internally within the ecosystem.
System DeFi for Reference (SDR) is the savings and functionality token only operational
within the system. DSR now brings an additional layer of value-added operations that
are unique and complementary to the whole system. As with the SDR and RSD tokens, DSR
is unique. The token's functionality employs a combination of automated functions to
generate internally and externally resourced value to token the while improving the
internal operational value to reward users and holders of the tokens. The token will
bring additional value to the token, its holders and users, and the entire RSD | SDR |
DSR ecosystem.

Tokenomics: The DSR token and its underlying value will have three major influences:
collateral, supply/demand and the external value generators. DSR will work to solve a
liquidity problem that occurs with many tokens. It takes advantage of a two part
system, tokens are only mintable (or unlocked) with an equitable amount of collateral
and a deposit into the external fund. This external fund is a potential source of
nearly constant (per block) profit creation and distribution to the contract and the
holders of DSR. DSR also brings an additional layer of value-added operations by
activating RSD and its functionality. The DSR contract also engages RSD's Proof of
Bet (PoBet) function, the DSR contract enables the automated generation of liquidity
by using the PoBet to reward itself RSD tokens and then mint DSR to be used to create
RSD/DSR liquidity on a designated exchange on each network (Pancakeswap / Spookyswap /
Quickswap / etc). This mechanism creates secondary and independent liquidity for RSD
holders.

Collateral: No DSR tokens will be created without native deposited into the smart
contract. The collateral is split into two sections. One is a pool of collateral that
operates as the foundation for the liquidity for DSR operation. The other is the
external manager fund. This collateral will be split between 'locked' (manager fund)
and 'liquid' (liquidity) portions. This collateral is one of the foundations for
maintaining a more valuable and less unstable token.

Supply/Demand: The individual users who interact with the DSR tokens will affect the
token price as with any other token. DSR will have a primary (interacting directly
with the contract) and the secondary market. DSR also uses the functionality built
into the RSD token. It calls PoBet from RSD on every transaction and if rewards are
received, DSR is paired with the earned RSD and sent to one of the network exchanges
to support RSD/DSR liquidity. So Buying, selling, exchanging, and other DSR activities
will have a secondary reward functionality, and provides a liquidity option for RSD
holders. Since the DSR minting is directly tied to collateral, the token should have
a solid base of value support and can build upon it with the actions of the automated
fund managers.

Externally Sourced Added Value: An excellent addition to DSR that is normally not seen
in other tokens beyond requiring collateral to mint and the automated liquidity creation
is the use of an external profit generation fund. Normal liquidity pairs have one
function to provide liquidity for a token's activity and transactions. DSR is different,
it employs all of the collateral to support and build the token. Beyond providing
liquidity for DSR activity, automated managers use the locked portion of collateral as
a fund that operates outside the ecosystem to generate additional sources of profit for
the token. When profits occur, these are sent back to the DSR contract as collateral to
mint new DSR token and then distributed across all DSR holders. Since the rewards are
collateralized, prior to distribution, this generates the rewards to the holders without
negatively affecting the value of the token...

The Automated Fund Managers: these are the autonomous functions built and deployed for
DSR. These manage the internal and external operations for the token, most importantly
the profit collection and distribution operations. Once deployed, the managers operate
autonomously. When available, these collect revenue from the fund operating on an
external finance platform, mint and distribute DSR. Nothing is constant in the crypto
universe, but these managers will be working to collect profit from outside the
ecosystem and bring the value into the ecosystem. Important note, any user can call
the profit function [checkForProfit()] and get part of a direct distribution, in the
form of native cryptocurrency into their wallet.

Obtaining DSR tokens: DSR is available in exchange for native tokens, RSD, and SDR
tokens. Native (layer 1 tokens)/DSR are the primary pair. RSD/DSR and SDR/DSR are other
exchange pairs. There are two primary collateral funds and the investor/users build
those funds by obtaining DSR. There are two methods to obtain the token: with and
without a 'locked' portion of the funds. The funds in either case use Layer 1 tokens.
The team will take a 1% commission from every initial investment.

The partially 'locked funds' method: The individual sends an amount of Layer 1 (native)
tokens, for example 100 MATIC to the contract. In this case, 1 Matic commission goes to
the team, then half (~49.5 MATIC) of the remaining value will be locked in the automated
manager fund. The other half (~49.5 MATIC) of the remaining value will be collateral to
mint DSR. The sender will receive 49.5 MATIC worth of DSR tokens plus and additional
amount of the 49.5 MATIC as incentive for interacting with the contract, which will be
immediately locked in his wallet. This ensures all minted tokens have collateral in the
contract. The locked DSR will be unlocked gradually and proportionally as managers'
profits are sent back to the contract. In addition, an amount of SDR tokens inside the
DSR contract will also be deposited in the individual's wallet representing a bonus from
the manager fund (as long as there are SDR funds remaining in the DSR contract fund).
The liquid portion will stay in the DSR contract to provide liquidity, the 'locked'
portion will be held in the automated manager fund for use by the fund managers for
profit generation.

The 'unlocked' method: This is primarily a secondary market exchange. The source of
these tokens will be holders of DSR, not the contract. The individual exchanges Layer 1
cryptocurrency for the DSR token on an exchange, just like with any direct exchange,
no additional bonus will be given. This will not "lock" any of the value of the exchanged
tokens to the individual. This method will not mint new DSR tokens and since this is a
secondary market transaction, it is subject to availability of DSR tokens on LPs. The
holders of the DSR token will start to earn DSR upon obtaining these secondary market at
the same rate as an initial investor.

Holding, and using DSR tokens: The holders of the DSR tokens only will begin to receive
continuous incremental rewards upon receiving their DSR tokens. The rewards will show up
as additional DSR tokens in the individual's wallet. The holders of 'locked funds' will
receive incremental awards in both their DSR and SDR tokens, since both provide incremental
"rewards". SDR rewards holders based on the community’s activity with SDR token's infinite
farm system. Due to the nature of the 'locked value', those holders will require additional
time to return to the initial value, however these holders will be generating rewards from
holding the DSR, locked DSR, and SDR tokens.

The Ecosystem Dynamics: The most unique part of the ecosystem in general, is that all of
the tokens are dynamic and have functionality built into each token. Activity-based supply
stability functionality (RSD), multiple tokens using PoBet functionality (RSD & DSR), the
'Infinite Farm' reward system (SDR), and now automated managers taking external profit,
building collateral and redistributing rewards to holders (DSR). No other ecosystem has
tokens built specifically to create value while being held and used.

Deployment: Initially DSR will be deployed on three networks. Binance Smart Chain (BSC),
Polygon (Matic/Poly), and Fantom (FTM) will have tokens with their automated manager smart
contracts deployed. The rollout to the other networks will happen shortly after as
additional automated manager smart contracts are tested and finalized. Based on activity
level, some networks will have multiple manager smart contracts, some will have only one
manager smart contract. Once DSR contracts are deployed on all the networks with RSD and
SDR, the team will be monitoring collateral and token activity levels to gauge the necessity
to expand the number of managers.
---------------------------------------------------------------------------------------

REVERT/REQUIRE CODE ERRORS:
DSR01: please refer you can call this function only once at a time until it is fully executed
DSR02: only managers can call this function
DSR03: manager was added already
DSR04: informed manager does not exist in this contract anymore
DSR05: the minimum amount of active managers is one
DSR06: direct investments in the contract are paused
---------------------------------------------------------------------------------------
*/
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IReferenceSystemDeFi.sol";
import "./IWETH.sol";
import "./IManager.sol";
import "./DsrHelper.sol";

contract DeFiSystemReference is IERC20, Ownable {

    using SafeMath for uint256;

		bool private _isTryPoBet = false;
		bool private _isFirstMint = true;
		bool private _isMintLocked = false;
    bool private _areInvestmentsPaused = false;

		address public exchangeRouterAddress;
		address private rsdTokenAddress;
		address private sdrTokenAddress;

		address public dsrHelperAddress;
		address public developerComissionAddress;

    uint8 private _decimals = 18;
    uint256 private _totalSupply;

		uint256 private _countProfit;
		uint256 private _currentBlockCheck;
		uint256 private _currentBlockTryPoBet;
		uint256 private _lastBlockWithProfit;
		uint256 private _totalNumberOfBlocksForProfit;
		uint256 private constant _FACTOR = 10**36;
		uint256 private constant _MAGNITUDE = 2**128;

		uint256 private lastTotalProfit;
		uint256 private constant liquidityProfitShare = (60 * _FACTOR) / 100; // 60.00%
		uint256 private developerComissionRate = _FACTOR / 100; // 1.00%
		uint256 private checkerComissionRate = (2 * _FACTOR) / 1000; // 0.20%
		uint256 private dividendRate;
    uint256 private countInvestment;
		uint256 public totalProfit;

		mapping (address => uint256) private _balances;
		mapping (address => uint256) private _currentProfitSpent;
    mapping (address => uint256) private _lockedBalances;
		mapping (address => mapping (address => uint256)) private _allowances;

		address[] private managerAddresses;
    address[5] public assetPairs;

    string private _name;
    string private _symbol;

		IWETH private _wEth;

		event ProfitReceived(uint256 amount);

		modifier lockMint() {
			require(!_isMintLocked, "DSR01");
			_isMintLocked = true;
			_;
			_isMintLocked = false;
		}

    constructor (string memory name_, string memory symbol_) {
      _name = name_;
      _symbol = symbol_;
  		_mint(address(this), 1);
  		_isFirstMint = false;
    }

    receive() external payable {
			if (msg.sender != dsrHelperAddress)
				invest(msg.sender);
    }

    fallback() external payable {
			require(msg.data.length == 0);
			if (msg.sender != dsrHelperAddress)
				invest(msg.sender);
    }

    function name() public view returns (string memory) {
      return _name;
    }

    function symbol() public view returns (string memory) {
      return _symbol;
    }

    function decimals() public view returns (uint8) {
      return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
      return _totalSupply;
    }

    function availableBalanceOf(address account) public view returns (uint256) {
      return _balances[account].add(potentialProfitPerAccount(account));
    }

    function balanceOf(address account) public view override returns (uint256) {
			if (account == address(this)
				|| account == dsrHelperAddress
				|| account == assetPairs[0]
				|| account == assetPairs[1]
				|| account == assetPairs[2])
				// DSR smart contracts and DSR Helper do not participate in the profit sharing
				return _balances[account];
			else
				return (potentialBalanceOf(account).sub(_currentProfitSpent[account]));
    }

    function lockedBalanceOf(address account) public view returns (uint256) {
      if (account == address(this)
        || account == dsrHelperAddress
        || account == assetPairs[0]
        || account == assetPairs[1]
        || account == assetPairs[2])
        return _balances[account];
      else
        return (_lockedBalances[account]);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool success) {
      success = _transfer(msg.sender, recipient, amount);
      return success;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
      return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
      _approve(msg.sender, spender, amount);
      return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool success) {
      success = _transfer(sender, recipient, amount);
      _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
      return success;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
      _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
      return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
      _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
      return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual returns (bool success) {
			require(sender != address(0), "ERC20: transfer from the zero address");
			require(recipient != address(0), "ERC20: transfer to the zero address");

			_beforeTokenTransfer(sender, recipient, amount);

			uint256 senderBalance = availableBalanceOf(sender);
			require(senderBalance >= amount, "ERC20: transfer amount exceeds balance or there are funds locked");
			uint256 potentialProfitPerAccount_ = potentialProfitPerAccount(sender);
			if (potentialProfitPerAccount_ > 0 && _currentProfitSpent[sender] < potentialProfitPerAccount_) {
				uint256 profitSpendable = potentialProfitPerAccount_.sub(_currentProfitSpent[sender]);
        // We now unlock some funds for that sender, since the contract now has provided enough liquidity from profit
        if (profitSpendable >= _lockedBalances[sender]) {
          _balances[sender] = _balances[sender].add(_lockedBalances[sender]);
          _lockedBalances[sender] = 0;
        } else {
          _balances[sender] = _balances[sender].add(profitSpendable);
          _lockedBalances[sender] = _lockedBalances[sender].sub(profitSpendable);
        }
				if (amount <= profitSpendable) {
					// Transfer only profit or part of it for the desired amount
					_currentProfitSpent[sender] = _currentProfitSpent[sender].add(amount);
				} else {
					// Transfer all profit and part of balance for the desired amount
					uint256 spendableDifference = amount.sub(profitSpendable);
					_balances[sender] = _balances[sender].sub(spendableDifference);
					// Calculate new profit spent in order to allow the sender to continue participating in the next profit cycles, regularly
					_currentProfitSpent[sender] = potentialProfitPerAccount(sender);
				}
			} else {
				_balances[sender] = senderBalance.sub(amount);
        _currentProfitSpent[sender] = potentialProfitPerAccount(sender);
			}

			// To avoid the recipient be able to spend an unavailable or inexistent profit we consider he already spent the current claimable profit
			// He will be able to earn profit in the next cycle, after the call of receiveProfit() function
			if (_balances[recipient] == 0) {
				_balances[recipient] = _balances[recipient].add(amount);
				_currentProfitSpent[recipient] = potentialProfitPerAccount(recipient);
			} else {
				uint256 previousSpendableProfitRecipient = potentialProfitPerAccount(recipient);
				_balances[recipient] = _balances[recipient].add(amount);
				uint256 currentSpendableProfitRecipient = potentialProfitPerAccount(recipient);
				_currentProfitSpent[recipient] = currentSpendableProfitRecipient.sub(previousSpendableProfitRecipient);
			}

			emit Transfer(sender, recipient, amount);
	    return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
			require(account != address(0), "ERC20: mint to the zero address");

			_beforeTokenTransfer(address(0), account, amount);

			_totalSupply = _totalSupply.add(amount);
      if (account != address(this) && account != dsrHelperAddress) {
			  _balances[account] = _balances[account].add(amount.div(2));
        _lockedBalances[account] = _lockedBalances[account].add(amount.div(2));
      } else {
        _balances[account] = _balances[account].add(amount);
      }
			// It cannot mint more amount than invested initially, even with profit
			_currentProfitSpent[account] = potentialProfitPerAccount(account);
			emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
			require(account != address(0), "ERC20: burn from the zero address");

			_beforeTokenTransfer(account, address(0), amount);

			uint256 burnBalance = availableBalanceOf(account);
			require(burnBalance >= amount, "ERC20: burn amount exceeds balance (allowed)");
			uint256 potentialProfitPerAccount_ = potentialProfitPerAccount(account);
			if (potentialProfitPerAccount_ > 0 && _currentProfitSpent[account] < potentialProfitPerAccount_) {
				uint256 profitSpendable = potentialProfitPerAccount_.sub(_currentProfitSpent[account]);
        if (profitSpendable >= _lockedBalances[account]) {
          _balances[account] = _balances[account].add(_lockedBalances[account]);
          _lockedBalances[account] = 0;
        } else {
          _balances[account] = _balances[account].add(profitSpendable);
          _lockedBalances[account] = _lockedBalances[account].sub(profitSpendable);
        }
				if (amount <= profitSpendable) {
					_currentProfitSpent[account] = _currentProfitSpent[account].add(amount);
				} else {
					uint256 spendableDifference = amount.sub(profitSpendable);
          uint256 additionalDifference;
          if (spendableDifference > _balances[account]) {
            additionalDifference = spendableDifference.sub(_balances[account]);
            _balances[account] = 0;
            if (additionalDifference > _lockedBalances[account])
              _lockedBalances[account] = 0;
            else
              _lockedBalances[account] = _lockedBalances[account].sub(additionalDifference);
          } else {
					  _balances[account] = _balances[account].sub(spendableDifference);
          }
					_currentProfitSpent[account] = potentialProfitPerAccount(account);
				}
			} else {
				_balances[account] = burnBalance.sub(amount);
        _currentProfitSpent[account] = potentialProfitPerAccount(account);
			}
			_totalSupply = _totalSupply.sub(amount);
			emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {
      checkForProfit();
			tryPoBet(uint256(sha256(abi.encodePacked(from, to, amount))));
    }

		// RESOURCE ALLOCATION STRATEGY - FOR EARNED PROFIT
		function _allocateProfit(bool mustChargeComission) private {
			uint256 profit = address(this).balance; // Assuming the profit was received as regular ETH instead of wrapped ETH

			// 1. Calculate the amounts
			uint256 checkComission = (profit.mul(checkerComissionRate)).div(_FACTOR);
			uint256 devComission = (profit.mul(developerComissionRate)).div(_FACTOR);
			uint256 liqLocked = (profit.mul(liquidityProfitShare)).div(_FACTOR);

			// 2. Separate the profit amount for checkers
			if (!isManagerAdded(msg.sender)) {
				profit = profit.sub(checkComission);
				_chargeComissionCheck(checkComission);
			}

			// 3. Pay commission for the developer team
			if (mustChargeComission) {
				profit = profit.sub(devComission);
				_chargeComissionDev(devComission);
			}

			// 4. Allocate resources for the DSR/ETH LP
			profit = profit.sub(liqLocked.div(2));
			DsrHelper dsrHelper = DsrHelper(payable(dsrHelperAddress));
			uint256 dsrForEthAmount = (liqLocked.div(2).mul(dsrHelper.getPoolRate(assetPairs[0], address(this), address(_wEth)))).div(_FACTOR); // DSR -> ETH
			_mint(dsrHelperAddress, dsrForEthAmount);
			if (!dsrHelper.addLiquidityDsrEth{value: liqLocked.div(2)}()) {
				_burn(dsrHelperAddress, dsrForEthAmount);
			} // DSR + ETH

			// 5. Allocate resources for the DSR/RSD LP and DSR/SDR LP - ETH remaining used for liquidity
			profit = profit.sub(liqLocked.div(2));
			payable(dsrHelperAddress).transfer(liqLocked.div(2));
			try dsrHelper.swapEthForRsd() {
				uint256 rsdAmount = IReferenceSystemDeFi(rsdTokenAddress).balanceOf(dsrHelperAddress).div(2);
				uint256 dsrForRsdAmount = (rsdAmount.mul(dsrHelper.getPoolRate(assetPairs[1], address(this), rsdTokenAddress))).div(_FACTOR); // DSR -> RSD
				_mint(dsrHelperAddress, dsrForRsdAmount);
				try dsrHelper.addLiquidityDsrRsd(true) { } catch {
					_burn(dsrHelperAddress, dsrForRsdAmount);
				} // DSR + RSD
			} catch { }

			if (dsrHelper.swapRsdForSdr()) {
				uint256 sdrAmount = IERC20(sdrTokenAddress).balanceOf(dsrHelperAddress);
				uint256 dsrForSdrAmount = (sdrAmount.mul(dsrHelper.getPoolRate(assetPairs[2], address(this), sdrTokenAddress))).div(_FACTOR); // DSR -> SDR
				_mint(dsrHelperAddress, dsrForSdrAmount);
				try dsrHelper.addLiquidityDsrSdr() { } catch {
					_burn(dsrHelperAddress, dsrForSdrAmount);
				} // DSR + SDR
			}

			// 6. Allocate remaining resources for the Manager(s)
			uint256 length_ = managerAddresses.length;
			if (length_ > 0) {
				uint256 share = profit.div(length_);
				for (uint256 i = 0; i < length_; i++) {
          if (msg.sender != managerAddresses[i]) {
					   try IManager(managerAddresses[i]).receiveResources{value: share}() { } catch { }
          }
				}
			}
		}

		// RESOURCE ALLOCATION STRATEGY - FOR INITIAL INVESTORS
		function _allocateResources() private {
			uint256 resources = address(this).balance;

			// 1. Calculate developer team comission and pay it
			uint256 devComission = (resources.mul(developerComissionRate)).div(_FACTOR);
			resources = resources.sub(devComission);
			_chargeComissionDev(devComission);

			// 2. Allocate resources for the DSR/ETH LP
      uint256 mainLiquidity = resources.div(2);
			resources = resources.sub(mainLiquidity);
			uint256 rate;
			DsrHelper dsrHelper = DsrHelper(payable(dsrHelperAddress));
			if (balanceOf(assetPairs[0]) == 0 || assetPairs[0] == address(0))
				 rate = dsrHelper.getPoolRate(assetPairs[3], rsdTokenAddress, address(_wEth));
			else
			   rate = dsrHelper.getPoolRate(assetPairs[0], address(this), address(_wEth));

			uint256 mainLiquidityValue = (mainLiquidity.mul(rate)).div(_FACTOR);
			uint256 amountToDsrEth = balanceOf(address(this));
			uint256 diffToMint = amountToDsrEth > mainLiquidityValue ? amountToDsrEth - mainLiquidityValue : mainLiquidityValue - amountToDsrEth;
			_mint(dsrHelperAddress, diffToMint);
			if (amountToDsrEth > 0)
				_transfer(address(this), dsrHelperAddress, amountToDsrEth);
			try dsrHelper.addLiquidityDsrEth{value: mainLiquidity}() {
        uint256 balanceDsrHelper = balanceOf(dsrHelperAddress);
        if (balanceDsrHelper > 0)
          _burn(dsrHelperAddress, balanceDsrHelper);
      } catch {// DSR + ETH
        _burn(dsrHelperAddress, balanceOf(dsrHelperAddress));
      }

			// 3. Allocate resources for the Manager(s)
			uint256 length_ = managerAddresses.length;
			if (length_ > 0) {
				uint256 share = resources.div(length_);
				for (uint256 i = 0; i < length_; i++) {
					try IManager(managerAddresses[i]).receiveResources{value: share}() { } catch { }
				}
			}
		}

		function _calculateProfitPerBlock() private {
			if (totalProfit.sub(lastTotalProfit) > 0) {
				_countProfit++;
				_totalNumberOfBlocksForProfit = _totalNumberOfBlocksForProfit.add(block.number.sub(_lastBlockWithProfit));
				_lastBlockWithProfit = block.number;
			}
			lastTotalProfit = totalProfit;
		}

		function _chargeComissionCheck(uint256 amount) private {
			payable(msg.sender).transfer(amount);
		}

		function _chargeComissionDev(uint256 amount) private {
			if (developerComissionAddress != address(0))
				payable(developerComissionAddress).transfer(amount);
		}

    function _detachManager(address managerAddress) private {
      require(isManagerAdded(managerAddress), "DSR04");
      uint256 length_ = managerAddresses.length;
      require(length_ > 1, "DSR05");
      address[] memory newManagerAddresses = new address[](length_ - 1);
      uint256 j = 0;
      for (uint256 i = 0; i < length_; i++) {
        address mAddress = managerAddresses[i];
        if (managerAddress != mAddress) {
          newManagerAddresses[j] = mAddress;
          j++;
        }
      }
      managerAddresses = newManagerAddresses;
    }

		function _rewardSdrInfiniteFarm(address investor, uint256 amountInvested) private {
			IERC20 sdr = IERC20(sdrTokenAddress);
			uint256 balanceSdr = sdr.balanceOf(address(this));
			if (balanceSdr > 0) {
				try sdr.transfer(investor, ((balanceSdr.div(5)).mul(amountInvested)).div(_totalSupply.div(countInvestment))) { } catch { }
			}
		}

		function addManager(address manager) public onlyOwner {
			require(!isManagerAdded(manager), "DSR03");
			managerAddresses.push(manager);
		}

    function burn(uint256 amount) public {
      _burn(msg.sender, amount);
    }

		function checkForProfit() public {
			if (_currentBlockCheck != block.number) {
				_currentBlockCheck = block.number;
				for (uint256 i = 0; i < managerAddresses.length; i++) {
          // It must check profit and call the receiveProfit() function after, but only if it does not revert, otherwise we should call it in the next block
					try IManager(managerAddresses[i]).checkForProfit() { } catch { }
				}
				_calculateProfitPerBlock();
			}
		}

    function detachManager(address managerAddress) public onlyOwner {
      _detachManager(managerAddress);
    }

		function getAverageNumberOfBlocksForProfit() public view returns(uint256) {
			return (_countProfit == 0) ? _countProfit : _totalNumberOfBlocksForProfit.div(_countProfit);
		}

		function getAverageProfitPerBlock() public view returns(uint256) {
			return (_totalNumberOfBlocksForProfit == 0) ? _totalNumberOfBlocksForProfit : totalProfit.div(_totalNumberOfBlocksForProfit);
		}

		function getDividendYield() public view returns(uint256) {
			return (_totalSupply == 0) ? _totalSupply : ((totalProfit.mul(_FACTOR)).div(_totalSupply));
		}

		function getDividendYieldPerBlock() public view returns(uint256) {
			return (_totalNumberOfBlocksForProfit == 0) ? _totalNumberOfBlocksForProfit : getDividendYield().div(_totalNumberOfBlocksForProfit);
		}

    function initializePair(address factoryAddress, address asset01, address asset02, uint256 index) public onlyOwner {
      IUniswapV2Factory factory = IUniswapV2Factory(factoryAddress);
      assetPairs[index] = factory.getPair(asset01, asset02);
      if (assetPairs[index] == address(0))
        assetPairs[index] = factory.createPair(asset01, asset02);
    }

		function invest(address investor) public payable lockMint {
      require(!_areInvestmentsPaused, "DSR06");
			if (msg.value > 0) {
				uint256 rate;
				if (balanceOf(assetPairs[0]) == 0 || assetPairs[0] == address(0)) {
					rate = DsrHelper(payable(dsrHelperAddress)).getPoolRate(assetPairs[3], rsdTokenAddress, address(_wEth));
					_lastBlockWithProfit = block.number;
				} else {
					rate = DsrHelper(payable(dsrHelperAddress)).getPoolRate(assetPairs[0], address(this), address(_wEth));
				}
				uint256 amountInvested = ((msg.value).mul(rate)).div(_FACTOR);
        amountInvested = amountInvested.sub((amountInvested.mul(developerComissionRate)).div(_FACTOR));
				_mint(investor, amountInvested);
        countInvestment++;
				_rewardSdrInfiniteFarm(investor, amountInvested);
				_allocateResources();
			}
		}

		function isManagerAdded(address manager) public view returns(bool) {
			for (uint256 i = 0; i < managerAddresses.length; i++)
				if (manager == managerAddresses[i])
					return true;
			return false;
		}

		function obtainRandomWalletAddress(uint256 someNumber) public view returns(address) {
			return address(bytes20(sha256(abi.encodePacked(
					block.timestamp,
					block.number,
          block.difficulty,
          block.coinbase,
					_totalSupply,
					msg.sender,
					IReferenceSystemDeFi(rsdTokenAddress).totalSupply(),
					someNumber
				))));
		}

    function pauseInvestments() external onlyOwner {
      _areInvestmentsPaused = true;
    }

		function potentialBalanceOf(address account) public view returns(uint256) {
      return availableBalanceOf(account).add(_lockedBalances[account]);
		}

		function potentialProfitPerAccount(address account) public view returns(uint256) {
			if (account == address(this)
				|| account == dsrHelperAddress
				|| account == assetPairs[0]
				|| account == assetPairs[1]
				|| account == assetPairs[2]) {
				return 0;
			} else {
				return (((_balances[account].add(_lockedBalances[account])).mul(dividendRate)).div(_MAGNITUDE));
      }
		}

		function receiveProfit(bool mustChargeComission) external virtual payable lockMint {
			require(isManagerAdded(msg.sender) || msg.sender == owner(), "DSR02");
			if (msg.value > 0) {
				uint256 value = ((msg.value).mul(DsrHelper(payable(dsrHelperAddress)).getPoolRate(assetPairs[0], address(this), address(_wEth)))).div(_FACTOR);
				dividendRate = dividendRate.add((value.mul(_MAGNITUDE)).div(_totalSupply));
				totalProfit = totalProfit.add(value);
				_totalSupply = _totalSupply.add(value);
				_allocateProfit(mustChargeComission);
				emit ProfitReceived(value);
			}
		}

		function removeManager(address managerAddress) external onlyOwner {
      IManager manager = IManager(managerAddress);
      manager.withdrawInvestment();
      manager.setDsrTokenAddress(address(0));
      _detachManager(managerAddress);
		}

		// here the DSR token contract tries to earn some RSD tokens in the PoBet system. The earned amount is then locked in the DSR/RSD LP
		function tryPoBet(uint256 someNumber) public {
			if(!_isTryPoBet && !_isFirstMint) {
				_isTryPoBet = true;
				if (_currentBlockTryPoBet != block.number) {
					_currentBlockTryPoBet = block.number;
					IReferenceSystemDeFi rsd = IReferenceSystemDeFi(rsdTokenAddress);
					uint256 rsdBalance = rsd.balanceOf(address(this));
					try rsd.transfer(obtainRandomWalletAddress(someNumber), rsdBalance) {
						if (assetPairs[1] != address(0)) {
							DsrHelper dsrHelper = DsrHelper(payable(dsrHelperAddress));
							uint256 newRsdBalance = rsd.balanceOf(address(this));
							// it means we have won the PoBet prize! Woo hoo! So, now we lock liquidity in DSR/RSD LP with this earned amount!
							if (rsdBalance < newRsdBalance) {
								uint256 earnedRsd = newRsdBalance.sub(rsdBalance);
                uint256 balanceDsr = balanceOf(address(this));
								if (balanceDsr == 0) {
                  rsd.transfer(dsrHelperAddress, earnedRsd);
                  earnedRsd = rsd.balanceOf(dsrHelperAddress);
                  if (balanceOf(assetPairs[1]) == 0) {
                    // We follow the rate of RSD in the RSD/ETH LP
                    _mint(dsrHelperAddress, earnedRsd);
									} else {
										// We follow the rate of DSR in the DSR/RSD LP
                    _mint(dsrHelperAddress, (earnedRsd.mul(dsrHelper.getPoolRate(assetPairs[1], address(this), rsdTokenAddress))).div(_FACTOR));
                  }
								} else {
                  uint256 dsrAmountToTransfer;
                  rsd.transfer(dsrHelperAddress, earnedRsd);
                  earnedRsd = rsd.balanceOf(dsrHelperAddress);
									if (balanceOf(assetPairs[1]) == 0) {
                    dsrAmountToTransfer = earnedRsd;
									} else {
                    dsrAmountToTransfer = (earnedRsd.mul(dsrHelper.getPoolRate(assetPairs[1], address(this), rsdTokenAddress))).div(_FACTOR);
                  }
                  _transfer(address(this), dsrHelperAddress, balanceDsr);
                  if (dsrAmountToTransfer > balanceDsr)
                    _mint(dsrHelperAddress, (dsrAmountToTransfer - balanceDsr));
								}
                dsrHelper.addLiquidityDsrRsd(false);
						  }
            }
					} catch { }
					// we also help to improve randomness of the RSD token contract after trying the PoBet system
					rsd.generateRandomMoreThanOnce();
				}
				_isTryPoBet = false;
			}
		}

		function setCheckerComissionRate(uint256 comissionRate) external onlyOwner {
			checkerComissionRate = comissionRate;
		}

		function setDeveloperComissionRate(uint256 comissionRate) external onlyOwner {
			developerComissionRate = comissionRate;
		}

    function setDeveloperComissionAddress(address developerComissionAddress_) external onlyOwner {
      developerComissionAddress = developerComissionAddress_;
    }

    function setDsrHelperAddress(address dsrHelperAddress_) external onlyOwner {
      dsrHelperAddress = dsrHelperAddress_;
    }

    function setExchangeRouter(address exchangeRouterAddress_) external onlyOwner {
      exchangeRouterAddress = exchangeRouterAddress_;
      IUniswapV2Router02 router = IUniswapV2Router02(exchangeRouterAddress_);
      _wEth = IWETH(router.WETH());
    }

		function setSdrTokenAddress(address sdrTokenAddress_) external onlyOwner {
			sdrTokenAddress = sdrTokenAddress_;
			DsrHelper(payable(dsrHelperAddress)).setSdrTokenAddress(sdrTokenAddress_);
		}

		function setRsdTokenAddress(address rsdTokenAddress_) external onlyOwner {
			rsdTokenAddress = rsdTokenAddress_;
			DsrHelper(payable(dsrHelperAddress)).setSdrTokenAddress(rsdTokenAddress_);
		}

    function unpauseInvestments() external onlyOwner {
      _areInvestmentsPaused = false;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IReferenceSystemDeFi is IERC20 {
    function burn(uint256 amount) external;
    function generateRandomMoreThanOnce() external;
    function getCrowdsaleDuration() external view returns(uint128);
    function getExpansionRate() external view returns(uint16);
    function getSaleRate() external view returns(uint16);
    function log_2(uint x) external pure returns (uint y);
    function mintForStakeHolder(address stakeholder, uint256 amount) external;
    function obtainRandomNumber(uint256 modulus) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IWETH {
		function approve(address to, uint amount) external returns (bool);
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IManager {
	function checkForProfit() external;
	function getExposureOfAccounts() external view returns(uint256, uint256);
	function queryPrice() external view returns(uint256);
	function receiveFromAccount() external payable;
	function receiveResources() external payable;
	function setDsrTokenAddress(address) external;
	function withdrawInvestment() external;
	function convertETHtoUSD(uint256) external view returns(uint256);
	function convertUSDtoETH(uint256) external view returns(uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";
import "./IWETH.sol";

contract DsrHelper is Context, Ownable {

	address internal dsrTokenAddress;
	address internal rsdTokenAddress;
	address internal sdrTokenAddress;
	address public exchangeRouterAddress;

	uint256 private constant FACTOR = 10**36;

	modifier fromDsrToken {
		require(_msgSender() == dsrTokenAddress || _msgSender() == owner(), "DSR Helper: only DSR token contract can call this function");
		_;
	}

	constructor(address dsrTokenAddress_, address exchangeRouterAddress_, address rsdTokenAddress_, address sdrTokenAddress_) {
		dsrTokenAddress = dsrTokenAddress_;
		exchangeRouterAddress = exchangeRouterAddress_;
		rsdTokenAddress = rsdTokenAddress_;
		sdrTokenAddress = sdrTokenAddress_;
	}

	receive() external payable {
	}

	fallback() external payable {
		require(msg.data.length == 0);
	}

	function addLiquidityDsrEth() external payable fromDsrToken returns(bool) {
		IERC20 dsr = IERC20(dsrTokenAddress);
		uint256 dsrTokenAmount = dsr.balanceOf(address(this));
		dsr.approve(exchangeRouterAddress, dsrTokenAmount);
		// add the liquidity for DSR/ETH pair
		try IUniswapV2Router02(exchangeRouterAddress).addLiquidityETH{value: msg.value}(
				address(dsr),
				dsrTokenAmount,
				0, // slippage is unavoidable
				0, // slippage is unavoidable
				address(0),
				block.timestamp+300
		) { return true; } catch { return false; }
	}

	function addLiquidityDsrRsd(bool halfRsd) external fromDsrToken returns(bool) {
		IERC20 dsr = IERC20(dsrTokenAddress);
		IERC20 rsd = IERC20(rsdTokenAddress);
		uint256 dsrTokenAmount = dsr.balanceOf(address(this));
		uint256 rsdTokenAmount = halfRsd ? rsd.balanceOf(address(this)) / 2 : rsd.balanceOf(address(this));
		// approve token transfer to cover all possible scenarios
		dsr.approve(exchangeRouterAddress, dsrTokenAmount);
		rsd.approve(exchangeRouterAddress, rsdTokenAmount);
		// add the liquidity for DSR/RSD pair
		try IUniswapV2Router02(exchangeRouterAddress).addLiquidity(
			address(dsr),
			address(rsd),
			dsrTokenAmount,
			rsdTokenAmount,
			0, // slippage is unavoidable
			0, // slippage is unavoidable
			address(0),
			block.timestamp+300
		) { return true; } catch { return false; }
	}

	function addLiquidityDsrSdr() external fromDsrToken returns(bool) {
		IERC20 dsr = IERC20(dsrTokenAddress);
		IERC20 sdr = IERC20(sdrTokenAddress);
		uint256 dsrTokenAmount = dsr.balanceOf(address(this));
		uint256 sdrTokenAmount = sdr.balanceOf(address(this));
		// approve token transfer to cover all possible scenarios
		dsr.approve(exchangeRouterAddress, dsrTokenAmount);
		sdr.approve(exchangeRouterAddress, sdrTokenAmount);
		// add the liquidity for DSR/SDR pair
		try IUniswapV2Router02(exchangeRouterAddress).addLiquidity(
			address(dsr),
			address(sdr),
			dsrTokenAmount,
			sdrTokenAmount,
			0, // slippage is unavoidable
			0, // slippage is unavoidable
			address(0),
			block.timestamp+300
		) { return true; } catch { return false; }
	}

	function getPoolRate(address pair, address asset01, address asset02) public view returns(uint256) {
		uint256 balance01 = IERC20(asset01).balanceOf(pair);
		uint256 balance02 = IERC20(asset02).balanceOf(pair);
		if (pair == address(0)) {
			return FACTOR;
		} else {
			balance01 = balance01 == 0 ? 1 : balance01;
			balance02 = balance02 == 0 ? 1 : balance02;
			return ((balance01 * FACTOR) / balance02);
		}
	}

	function swapEthForRsd() external virtual fromDsrToken returns(bool) {
		IUniswapV2Router02 router = IUniswapV2Router02(exchangeRouterAddress);
		// generate the pair path of ETH -> RSD on exchange router contract
		address[] memory path = new address[](2);
		path[0] = router.WETH();
		path[1] = rsdTokenAddress;

		try router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: address(this).balance}(
			0, // accept any amount of RSD
			path,
			address(this),
			block.timestamp+300
		) { return true; } catch { return false; }
	}

	function swapRsdForDsr() external fromDsrToken returns(bool) {
		IERC20 rsd = IERC20(rsdTokenAddress);
		uint256 tokenAmount = rsd.balanceOf(address(this));
		// generate the pair path of RSD -> DSR on exchange router contract
		address[] memory path = new address[](2);
		path[0] = rsdTokenAddress;
		path[1] = dsrTokenAddress;

		rsd.approve(exchangeRouterAddress, tokenAmount);

		try IUniswapV2Router02(exchangeRouterAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
			tokenAmount,
			0, // accept any amount of DSR
			path,
			address(this),
			block.timestamp+300
		) { return true; } catch { return false; }
	}

	function swapRsdForSdr() external fromDsrToken returns(bool) {
		IERC20 rsd = IERC20(rsdTokenAddress);
		uint256 tokenAmount = rsd.balanceOf(address(this));
		// generate the pair path of RSD -> SDR on exchange router contract
		address[] memory path = new address[](2);
		path[0] = rsdTokenAddress;
		path[1] = sdrTokenAddress;

		rsd.approve(exchangeRouterAddress, tokenAmount);

		try IUniswapV2Router02(exchangeRouterAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
			tokenAmount,
			0, // accept any amount of SDR
			path,
			address(this),
			block.timestamp+300
		) { return true; } catch { return false; }
	}

	function setDsrTokenAddress(address dsrTokenAddress_) external fromDsrToken {
		dsrTokenAddress = dsrTokenAddress_;
	}

	function setSdrTokenAddress(address sdrTokenAddress_) external fromDsrToken {
		sdrTokenAddress = sdrTokenAddress_;
	}

	function setRsdTokenAddress(address rsdTokenAddress_) external fromDsrToken {
		rsdTokenAddress = rsdTokenAddress_;
	}

	function withdrawTokensSent(address tokenAddress) external fromDsrToken {
		IERC20 token = IERC20(tokenAddress);
		uint256 balance = token.balanceOf(address(this));
		if (balance > 0)
			token.transfer(_msgSender(), balance);
	}

	function withdrawEthSent(address payable accountAddress) external fromDsrToken {
		accountAddress.transfer(address(this).balance);
	}
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
pragma solidity >=0.8.0;

import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactAVAXForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForAVAXSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function WAVAX() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}