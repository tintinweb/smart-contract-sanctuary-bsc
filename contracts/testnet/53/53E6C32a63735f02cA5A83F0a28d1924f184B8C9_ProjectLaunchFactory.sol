// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {Sale} from "./contracts/Sale_V4.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface iCoupon {
  function getCouponDiscount(address _address) external view returns (uint256 _couponDiscount);
  function getCouponActive(address _address) external view returns (uint _couponActive);
}

interface iBlacklist {
    function getBlacklist(address _address, address _contract) external view returns (uint is_blacklisted);
}

contract ProjectLaunchFactory {

  using Address for address payable;
  using SafeMath for uint256;

  address public blacklistContract = 0x9844568F3E376Fc0363E634D7D54D1EEa1969440;
  address couponContract = 0xE039660A6221BC3a98B7228f2bc116d885860A18;
  address _address = msg.sender;
  address _contract = address(this);

  address public feeTo;
  address _owner;
  mapping(uint => uint256) public launchFee;
  mapping(uint => uint256) public round1Mult;
  mapping(uint => uint256) public round2Mult;
  mapping(uint => uint256) public round3Mult;

  struct commonData {
    address msg_sender;
    address _sale_token;
  }

  modifier enoughFee(uint _option) {
    require(msg.value >= launchFee[_option], "Flat fee");
    _;
  }

  modifier onlyOwner {
    require(msg.sender == _owner, "You are not owner");
    _;
  }

  constructor() {
    feeTo = msg.sender;

    launchFee[1] = 5_000_000 gwei;
    launchFee[2] = 7_500_000 gwei;
    launchFee[3] = 7_500_000 gwei;
    launchFee[4] = 10_000_000 gwei;
    launchFee[5] = 10_000_000 gwei;

    round1Mult[1] = 99;
    round2Mult[1] = 92;
    round3Mult[1] = 96;

    round1Mult[2] = 99;
    round2Mult[2] = 94;
    round3Mult[2] = 97;

    round1Mult[3] = 99;
    round2Mult[3] = 96;
    round3Mult[3] = 98;

    round1Mult[4] = 96;
    round2Mult[4] = 96;
    round3Mult[4] = 96;

    round1Mult[5] = 98;
    round2Mult[5] = 98;
    round3Mult[5] = 98;

    _owner = msg.sender;
  }

  function setFeeTo(address feeReceivingAddress) external onlyOwner {
    feeTo = feeReceivingAddress;
  }

  function setRoundMultiplier(uint _option, uint256 _round1Mult, uint256 _round2Mult, uint256 _round3Mult) external onlyOwner {
    round1Mult[_option] = _round1Mult;
    round2Mult[_option] = _round2Mult;
    round3Mult[_option] = _round3Mult;
  }

  function setLaunchFee(uint _option, uint256 _fee) external onlyOwner {
    launchFee[_option] = _fee;
  }

  function refundExcessiveFee(uint _option) internal {
    uint256 refund = msg.value.sub(launchFee[_option]);
    if (refund > 0) {
      payable(msg.sender).sendValue(refund);
    }
  }

  function createSale(
    address _sale_token,
    uint256[] memory _sale_details,
    uint256[] memory _seed_details,
    uint256[] memory _seed_vesting,
    uint256[] memory _presale_details,
    uint256[] memory _presale_vesting,
    uint256[] memory _community_details,
    uint256[] memory _community_vesting,
    uint256[] memory _options
  ) external payable enoughFee(_options[0]) returns (address) {
    refundExcessiveFee(_options[0]);
    _sale_details[4] = launchFee[_options[0]];
    _sale_details[5] = iCoupon(couponContract).getCouponDiscount(_address);
    _seed_details[8] = round1Mult[_options[0]];
    _presale_details[8] = round1Mult[_options[0]];
    _community_details[8] = round1Mult[_options[0]];

    Sale sale = new Sale(
      msg.sender,
      _sale_token,
      _sale_details,
      _seed_details,
      _seed_vesting,
      _presale_details,
      _presale_vesting,
      _community_details,
      _community_vesting,
      _options
    );
    if (iCoupon(couponContract).getCouponActive(_address) == 1) {
      payable(feeTo).transfer((launchFee[_options[0]])*(100-((iCoupon(couponContract).getCouponDiscount(_address)))/100));
    } else {
      payable(feeTo).transfer(launchFee[_options[0]]);
    }
    require((_sale_details[1] > block.timestamp), "You Must have at least one start time");
    require(iBlacklist(blacklistContract).getBlacklist(_address, _contract) == 0, 'You are blacklisted!');

    return address(sale);
  }

  function setNewBlacklist(address _newBlacklist) public onlyOwner {
    blacklistContract = _newBlacklist;
  }

  function setNewCoupon(address _newCoupon) public onlyOwner {
    couponContract = _newCoupon;
  }

  function setNewOwner(address _newOwner) public onlyOwner {
    _owner = _newOwner;
  }

  function getCurrentBlock(uint256 _currentBlock) public view {
    _currentBlock = block.timestamp;
  }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    // sends ETH or an erc20 token
    function safeTransferBaseToken(address token, address payable to, uint value, bool isERC20) internal {
        if (!isERC20) {
            to.transfer(value);
        } else {
            (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
        }
    }
}


interface IBEP20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function decimals() external view returns (uint8);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface iBlacklist {
    function getBlacklist(address _address, address _contract) external view returns (uint is_blacklisted);
}

interface iAuditor {
    function getVerified(address _contract) external view returns (uint256 is_verified);
}

contract Sale is ReentrancyGuard {
    using SafeMath for uint256;

    enum SaleType { SALEPUBLIC, SALEWHITELIST }

    struct SaleDetails {
        address sale_token;          // Sale token
        uint canceled;               // Canceled flag
        uint hasSeedRound;           // Sale has a seed round
        uint hasPresaleRound;        // Sale has a presale round
        uint hasCommunityRound;      // Sale has a community round
        uint256 listRate;            //
        uint saleOption;             //
        uint hasVesting;
        uint256 launchFee;
        uint256 coupon;
    }

    struct SaleInfo {
        uint256 token_rate;          // 1 base token = ? s_tokens, fixed price
        uint256 raise_min;           // Maximum base token BUY amount per buyer
        uint256 raise_max;           // The amount of sale tokens up for sale round
        uint256 softcap;             // Minimum raise amount
        uint256 hardcap;             // Maximum raise amount
        uint256 start;               // Start date of the sale
        uint256 end;                 // End date of the sale
        uint256 liquidity;           // Liquidity of the sale
        uint256 liquidityTokens;     //
        SaleType sale_type;          // Sale type, whitelist or public availability
        uint attempt;                // Attempt of the
        uint256 mult;
    }

    struct SaleVesting {
        uint256 TGE;                 // token generation event date
        uint256 TGE_amount;          // amount at the token generation amount
        uint256 cliff;               // cliff date
        uint256 period;              // Maximum raise amount
        uint256 period_amount;       // Start date of the sale
    }

    struct SaleStatus {
        uint force_failed;           // Set this flag to force fail the sale
        uint256 sale_raised_amount;  // Total base currency raised (usually ETH)
        uint256 sale_sold_amount;    // Total sale tokens sold
        uint256 sale_token_withdraw; // Total tokens withdrawn post successful sale
        uint256 sale_base_withdraw;  // Total base tokens withdrawn on sale failure
        uint256 sale_num_buyers;     // Number of unique participants
    }

    struct BuyerInfo {
        uint256 sale_base;           // Total base token (usually ETH) deposited by user, can be withdrawn on sale failure
        uint256 sale;                // Num sale tokens a user owned, can be withdrawn on sale success
        uint256 TGE_claimable;
        uint256 claimable;
        uint256 TGE_claimed;
        uint256 claimed;
    }

    struct TokenInfo {
        string name;                 //
        string symbol;               //
        uint256 totalsupply;         //
        uint256 decimal;             //
    }

    address owner;
    address public admin = 0x33F3ed84725FdbF32Ea78F3a576c0c35a92b7a7e;
    address public blacklistContract = 0x9844568F3E376Fc0363E634D7D54D1EEa1969440;
    address public auditorContract = 0xbdE7fc94527a84a856B65eC54803c71B923a54Ea;

    address _address = msg.sender;
    address _contract = address(this);

    SaleDetails internal sale_details;
    mapping(uint => SaleInfo) internal sale_info;
    mapping(uint => SaleVesting) internal sale_vesting;
    mapping(uint => SaleStatus) internal sale_status;
    mapping(uint => mapping(address => BuyerInfo)) internal buyers;
    TokenInfo internal tokeninfo;

    uint256 saleSetting;

    mapping(address => uint) internal saleWhitelistInfo;

    event SaleCreated(address, address);
    event UserDepsitedSuccess(address, uint256);
    event UserWithdrawSuccess(uint256);
    event UserWithdrawTokensSuccess(uint256);
    event UserWithdrawTokensVestingSuccess(uint256, uint256);

    address deadaddr = 0x000000000000000000000000000000000000dEaD;
    uint256 public sale_lock_delay;

    modifier onlyOwner() {
        require(owner == msg.sender, "Not sale owner.");
        _;
    }

    modifier IsSaleWhitelisted(uint _round) {
        require(sale_info[_round].sale_type == SaleType.SALEWHITELIST, "whitelist not set");
        _;
    }

    constructor(
        address owner_,
        address _sale_token,
        uint256[] memory _sale_details,
        uint256[] memory _seed_details,
        uint256[] memory _seed_vesting,
        uint256[] memory _presale_details,
        uint256[] memory _presale_vesting,
        uint256[] memory _community_details,
        uint256[] memory _community_vesting,
        uint256[] memory _options
    ) {
        owner = msg.sender;

        init_sale(
            _sale_token,
            _sale_details,
            _seed_details,
            _seed_vesting,
            _presale_details,
            _presale_vesting,
            _community_details,
            _community_vesting,
            _options
        );

        owner = owner_;

        emit SaleCreated(owner, address(this));
    }

    function init_sale (
        address _sale_token,
        uint256[] memory _sale_details,
        uint256[] memory _seed_details,
        uint256[] memory _seed_vesting,
        uint256[] memory _presale_details,
        uint256[] memory _presale_vesting,
        uint256[] memory _community_details,
        uint256[] memory _community_vesting,
        uint256[] memory _options
        ) public onlyOwner {

        require(saleSetting == 0, "Already setted");
        require(_sale_token != address(0), "Zero Address");
        uint256 totalTokens = 0;
        uint256 totalLiquidityTokens = 0;

        sale_details.sale_token = address(_sale_token);
        sale_details.hasSeedRound = 0;
        sale_details.hasPresaleRound = 0;
        sale_details.hasCommunityRound = 0;
        sale_details.listRate = _sale_details[0];
        sale_details.canceled = 0;
        sale_details.saleOption = _options[0];
        sale_details.hasVesting = _sale_details[1];
        sale_details.launchFee = _sale_details[2];
        sale_details.coupon = _sale_details[3];

        if(_seed_details[0] > 0) {
            sale_details.hasSeedRound = 1;

            setSaleDetails(1,_seed_details);
            if(sale_details.hasVesting == 1) {
                setSaleVesting(1, _seed_vesting);
            }

            totalLiquidityTokens = (totalLiquidityTokens + sale_info[1].liquidityTokens);
            totalTokens = (totalTokens + (sale_info[1].hardcap * sale_info[1].token_rate));
        }

        if(_presale_details[0] > 0) {
            sale_details.hasPresaleRound = 1;

            setSaleDetails(2,_presale_details);
            if(sale_details.hasVesting == 1) {
                setSaleVesting(2, _presale_vesting);
            }

            totalLiquidityTokens = (totalLiquidityTokens + sale_info[2].liquidityTokens);
            totalTokens = (totalTokens + (sale_info[2].hardcap * sale_info[2].token_rate));
        }

        if(_community_details[0] > 0) {
            sale_details.hasCommunityRound = 1;

            setSaleDetails(3,_community_details);
            if(sale_details.hasVesting == 1) {
                setSaleVesting(3, _community_vesting);
            }

            totalLiquidityTokens = (totalLiquidityTokens + sale_info[3].liquidityTokens);
            totalTokens = (totalTokens + (sale_info[3].hardcap * sale_info[3].token_rate));
        }

        //Set token token info
        tokeninfo.name = IBEP20(sale_details.sale_token).name();
        tokeninfo.symbol = IBEP20(sale_details.sale_token).symbol();
        tokeninfo.decimal = IBEP20(sale_details.sale_token).decimals();
        tokeninfo.totalsupply = IBEP20(sale_details.sale_token).totalSupply();

        IBEP20(sale_details.sale_token).approve(address(this),(totalTokens + totalLiquidityTokens));
        IBEP20(sale_details.sale_token).transferFrom(msg.sender,address(this),(totalTokens+totalLiquidityTokens));

        saleSetting = 1;

    }

    function setSaleDetails(uint _sale_round, uint256[] memory _sale_input) private {
        sale_info[_sale_round].token_rate = _sale_input[0];
        sale_info[_sale_round].raise_min = _sale_input[1];
        sale_info[_sale_round].raise_max = _sale_input[2];
        sale_info[_sale_round].softcap = _sale_input[3];
        sale_info[_sale_round].hardcap = _sale_input[4];
        sale_info[_sale_round].liquidity = _sale_input[5];
        sale_info[_sale_round].start = _sale_input[6];
        sale_info[_sale_round].end = _sale_input[7];
        sale_info[_sale_round].mult = _sale_input[8];

        if(sale_details.saleOption == 1) {
            sale_info[_sale_round].sale_type = SaleType.SALEWHITELIST;
        } else {
            sale_info[_sale_round].sale_type = SaleType.SALEPUBLIC;
        }

        sale_info[_sale_round].attempt = 1;

        sale_info[_sale_round].liquidityTokens = (sale_info[_sale_round].hardcap).mul(sale_info[_sale_round].mult).div(100).mul(sale_details.listRate).mul(sale_info[_sale_round].liquidity).div(100);
    }

    function setSaleVesting(uint _sale_round, uint256[] memory _sale_vesting) private {
        sale_vesting[_sale_round].TGE = _sale_vesting[0];
        sale_vesting[_sale_round].TGE_amount = _sale_vesting[1];
        sale_vesting[_sale_round].cliff = _sale_vesting[2];
        sale_vesting[_sale_round].period = _sale_vesting[3];
        sale_vesting[_sale_round].period_amount = _sale_vesting[4];
    }

    function setOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function saleStatus(uint _round) public view returns (uint256) {
        if(sale_details.canceled == 1) {
            return 4; // Canceled
        }
        if ((block.timestamp > sale_info[_round].end) && (sale_status[_round].sale_raised_amount < sale_info[_round].softcap)) {
            return 3; // Failure
        }
        if (sale_status[_round].sale_raised_amount >= sale_info[_round].hardcap) {
            return 2; // Wonderful - reached to Hardcap
        }
        if ((block.timestamp > sale_info[_round].end) && (sale_status[_round].sale_raised_amount >= sale_info[_round].softcap)) {
            return 2; // SUCCESS - sale ended with reaching Softcap
        }
        if ((block.timestamp >= sale_info[_round].start) && (block.timestamp <= sale_info[_round].end)) {
            return 1; // ACTIVE - Deposits enabled, now in sale
        }
            return 0; // QUED - Awaiting start block
    }

    function setSaleStatus(uint256 _saleStatus, uint256 _round) public nonReentrant {
        require(msg.sender == admin, 'You are not the admin!');
        if (_saleStatus == 3) {
            sale_info[_round].end == block.timestamp;
            saleStatus(_round) == 3;

        }
    }

    // Accepts msg.value for eth or _amount for ERC20 tokens
    function userDeposit (uint _round) public payable nonReentrant {
        require(iBlacklist(blacklistContract).getBlacklist(_address, _contract) == 0, 'You are blacklisted!');

        if(sale_info[_round].start > 0) {
            if((block.timestamp >= sale_info[_round].start && block.timestamp <= sale_info[_round].end)) {
                if(sale_info[_round].sale_type == SaleType.SALEWHITELIST) {
                    require(saleWhitelistInfo[msg.sender] == 1, "You are not whitelisted.");
                }
                require(saleStatus(_round) == 1, "Not Active");
                require(sale_info[_round].raise_min <= msg.value, "Balance is insufficent");
                require(sale_info[_round].raise_max >= msg.value, "Balance is too much");

                BuyerInfo storage buyer = buyers[_round][msg.sender];

                uint256 amount_in = msg.value;
                uint256 allowance = sale_info[_round].raise_max.sub(buyer.sale_base);
                uint256 remaining = sale_info[_round].hardcap - sale_status[_round].sale_raised_amount;

                allowance = allowance > remaining ? remaining : allowance;
                if (amount_in > allowance) {
                    amount_in = allowance;
                }

                uint256 tokensSold = amount_in.mul(sale_info[_round].token_rate);

                require(tokensSold > 0, "ZERO TOKENS");
                require(sale_status[_round].sale_raised_amount * sale_info[_round].token_rate <= IBEP20(sale_details.sale_token).balanceOf(address(this)), "Token remain error");

                if (buyer.sale_base == 0) {
                    sale_status[_round].sale_num_buyers++;
                }
                buyers[_round][msg.sender].sale_base = buyers[_round][msg.sender].sale_base.add(amount_in);
                buyers[_round][msg.sender].sale = buyers[_round][msg.sender].sale.add(tokensSold);
                buyers[_round][msg.sender].TGE_claimable = buyers[_round][msg.sender].TGE_claimable.add(tokensSold.mul(sale_vesting[_round].TGE_amount).div(100));
                buyers[_round][msg.sender].claimable = buyers[_round][msg.sender].claimable.add(tokensSold.sub(buyers[_round][msg.sender].TGE_claimable));
                sale_status[_round].sale_raised_amount = sale_status[_round].sale_raised_amount.add(amount_in);
                sale_status[_round].sale_sold_amount = sale_status[_round].sale_sold_amount.add(tokensSold);

                // return unused ETH
                if (amount_in < msg.value) {
                    payable(msg.sender).transfer(msg.value.sub(amount_in));
                }
            }
        }
        emit UserDepsitedSuccess(msg.sender, msg.value);
    }

    // withdraw sale tokens
    // percentile withdrawls allows fee on transfer or rebasing tokens to still work
    function userWithdrawTokens (uint _round) public nonReentrant {

        // sale withdrawl tokens
        if(sale_info[_round].end > 0) {
            if(block.timestamp > sale_info[_round].end) {
                require(saleStatus(_round) == 2, "Not succeeded"); // Success
                BuyerInfo storage buyer = buyers[_round][msg.sender];
                uint256 remaintoken = sale_status[_round].sale_sold_amount.sub(sale_status[_round].sale_token_withdraw);
                require(remaintoken >= buyer.sale, "Nothing to withdraw.");

                if(sale_details.hasVesting == 0) {
                    require(block.timestamp >= sale_info[_round].end + sale_lock_delay, "Token Locked."); // Lock duration check
                    TransferHelper.safeTransfer(address(sale_details.sale_token), msg.sender, buyer.sale);

                    sale_status[_round].sale_token_withdraw = sale_status[_round].sale_token_withdraw.add(buyer.sale);

                    buyer.claimed = buyer.sale;
                    buyer.sale = 0;
                    buyer.sale_base = 0;
                    buyer.claimable = 0;

                    emit UserWithdrawTokensSuccess(buyer.sale);
                } else {
                    require(block.timestamp >= sale_vesting[_round].TGE, "Token locked");

                    uint256 tge_claim_amount = 0;
                    uint256 claim_amount = 0;

                    if(buyer.TGE_claimed == 0) {
                        tge_claim_amount = tge_claim_amount.add(buyer.sale.mul(sale_vesting[_round].TGE_amount).div(100));

                        if(tge_claim_amount > buyer.TGE_claimable) {
                            tge_claim_amount = buyer.TGE_claimable;
                        } else {
                            tge_claim_amount = tge_claim_amount.sub(buyer.TGE_claimed);
                        }
                    }

                    if(block.timestamp >= sale_vesting[_round].cliff){
                        claim_amount = claim_amount.add(buyer.sale.mul(sale_vesting[_round].period_amount.mul(block.timestamp.sub(sale_vesting[_round].cliff).div(sale_vesting[_round].period))).div(100));

                        if(claim_amount > buyer.claimable) {
                            claim_amount = buyer.claimable;
                        } else {
                            claim_amount = claim_amount.sub(buyer.claimable);
                        }
                    }

                    TransferHelper.safeTransfer(address(sale_details.sale_token), msg.sender, (tge_claim_amount.add(claim_amount)));
                    sale_status[_round].sale_token_withdraw = sale_status[_round].sale_token_withdraw.add(tge_claim_amount.add(claim_amount));

                    buyer.claimed = buyer.claimed.add(claim_amount);
                    buyer.TGE_claimed = buyer.TGE_claimed.add(tge_claim_amount);
                    buyer.claimable = buyer.claimable.sub(claim_amount);
                    buyer.TGE_claimable = buyer.TGE_claimable.sub(tge_claim_amount);

                    if(buyer.claimable == 0) {
                        buyer.sale = 0;
                        buyer.sale_base = 0;
                    }

                    emit UserWithdrawTokensVestingSuccess(buyer.TGE_claimed, buyer.claimed);
                }
            }
        }
    }

    // On sale failure
    // Percentile withdrawls allows fee on transfer or rebasing tokens to still work
    function userWithdrawBaseTokens (uint _round) public nonReentrant {

        //sale userWithdrawBaseTokens
        if(sale_info[_round].end > 0) {
            if(block.timestamp > sale_info[_round].end) {
                require(saleStatus(_round) == 3 || sale_info[_round].attempt > 0, "Not eligible for withdraw"); // FAILED

                // Refund
                BuyerInfo storage buyer = buyers[_round][msg.sender];

                uint256 remainingBaseBalance = address(this).balance;

                require(remainingBaseBalance >= buyer.sale_base, "Nothing to withdraw.");

                sale_status[_round].sale_base_withdraw = sale_status[_round].sale_base_withdraw.add(buyer.sale_base);

                address payable receiver = payable(msg.sender);
                receiver.transfer(buyer.sale_base);

                if(msg.sender == owner) {
                    ownerWithdrawTokens(_round);
                    // return;
                }

                buyer.sale_base = 0;
                buyer.sale = 0;


                emit UserWithdrawSuccess(buyer.sale_base);
            }
        }
    }

    // On sale failure
    function ownerWithdrawTokens (uint _round) private onlyOwner {

        // sale ownerWithdrawTokens
        if(sale_info[_round].end > 0) {
            if(block.timestamp > sale_info[_round].end) {
                require(saleStatus(_round) == 3, "Only failed status."); // FAILED
                TransferHelper.safeTransfer(address(sale_details.sale_token), owner, IBEP20(sale_details.sale_token).balanceOf(address(this)));

                emit UserWithdrawSuccess(IBEP20(sale_details.sale_token).balanceOf(address(this)));
            }
        }
    }

    function purchaseICOCoin (uint _round) public nonReentrant onlyOwner {

        // sale purchaseICOCoin
        if(sale_info[_round].end > 0) {
            if(block.timestamp > sale_info[_round].end) {
                require(saleStatus(_round) == 2, "Not succeeded"); // Success

                address payable receiver = payable(msg.sender);
                receiver.transfer(address(this).balance);
            }
        }
    }

    function getTimestamp () public view returns (uint256) {
        return block.timestamp;
    }

    function setLockDelay (uint256 delay) public onlyOwner {
        sale_lock_delay = delay;
    }

    function remainingBurn(uint _round) public onlyOwner {

        // sale remainingBurn
        if(sale_info[_round].end > 0) {
            if(block.timestamp > sale_info[_round].end) {
                require(saleStatus(_round) == 2, "Not succeeded"); // Success
                require(sale_info[_round].hardcap * sale_info[_round].token_rate >= sale_status[_round].sale_sold_amount, "Nothing to burn");

                uint256 rushTokenAmount = sale_info[_round].hardcap * sale_info[_round].token_rate - sale_status[_round].sale_sold_amount;

                TransferHelper.safeTransfer(address(sale_details.sale_token), address(deadaddr), rushTokenAmount);
            }
        }
    }

    function setSaleWhitelist(uint _round) public onlyOwner {
        sale_info[_round].sale_type = SaleType.SALEWHITELIST;
    }

    function _addSaleWhitelistAddr(address addr) private onlyOwner {
        saleWhitelistInfo[addr] = 1;
    }

    function _deleteSaleWhitelistAddr(address addr) private onlyOwner {
        saleWhitelistInfo[addr] = 0;
    }

    function setSaleWhitelistInfo(uint _round, address[] memory user) public onlyOwner IsSaleWhitelisted(_round) {
        for(uint i = 0 ; i < user.length ; i ++) {
            _addSaleWhitelistAddr(user[i]);
        }
    }

    function deleteSaleWhitelistInfo(uint _round, address[] memory user) public onlyOwner IsSaleWhitelisted(_round) {
        for(uint i = 0 ; i < user.length ; i ++) {
            _deleteSaleWhitelistAddr(user[i]);
        }
    }

    function setSalePublic(uint _round) public onlyOwner  {
        sale_info[_round].sale_type = SaleType.SALEPUBLIC;
    }

    function setSaleCancel() public onlyOwner {
        sale_details.canceled = 1;
    }

    function getSaleSaleType (uint _round) public view returns (bool) {
        if(sale_info[_round].sale_type == SaleType.SALEPUBLIC) {
            return true;
        } else {
            return false;
        }
    }

    function getSaleStatus (uint _round) public view returns (uint256, uint256) {
        return (sale_info[_round].start, sale_info[_round].end);
    }

    function changeAdmin (address newAdmin) public {
        require(msg.sender == admin, "You are not the admin");
        admin = newAdmin;
    }

    function setNewBlacklist(address _newBlacklist) public {
        require(msg.sender == admin, 'You are not the admin!');
        blacklistContract = _newBlacklist;
    }

    function setNewAuditorContract(address _newAuditor) public  {
        require(msg.sender == admin, 'You are not the admin!');
        auditorContract = _newAuditor;
    }

    function changeRaiseAmountAdmin(uint _round, uint256 _min, uint256 _max) public {
        require(msg.sender == admin, 'You are not the admin!');

        sale_info[_round].raise_min = _min;
        sale_info[_round].raise_max = _max;
    }

    function changeDateAdmin(uint _round, uint256 _start, uint256 _end) public {
        require(msg.sender == admin, 'You are not the admin!');
        require(_start > block.timestamp, "Start has to be greater than now");
        require(_end > _start, "End date has to be greater than the start");

        sale_info[_round].start = _start;
        sale_info[_round].end = _end;
    }

    function changeVestingAdmin(uint _round, uint256[] memory _vesting) public {
        require(msg.sender == admin, 'You are not the admin!');
        require(sale_vesting[_round].TGE > sale_info[_round].end, "Vesting has to start after the round has finished");
        require(sale_vesting[_round].cliff > sale_info[_round].end, "Vesting has to start after the round has finished");
        require(sale_vesting[_round].cliff >= sale_vesting[_round].TGE, "Cliff has to be greater than or equal to the TGE");

        sale_vesting[_round].TGE = _vesting[0];
        sale_vesting[_round].TGE_amount = _vesting[1];
        sale_vesting[_round].cliff = _vesting[2];
        sale_vesting[_round].period = _vesting[3];
        sale_vesting[_round].period_amount = _vesting[4];
    }

    function restartRound(uint _round, uint256 _start, uint256 _end) public payable onlyOwner {
        require(block.timestamp > sale_info[_round].end, "Round has not ended, can't restart");
        require(saleStatus(_round) == 3, "Not failed.");
        require(_start > block.timestamp, "Start has to be greater than now");
        require(_end > _start, "End date has to be greater than the start");
        require(_round == 3 || (_end < sale_info[_round.add(1)].start), "Need to change the next round's dates first");

        uint256 restartFee = sale_details.coupon >= 50 ? sale_details.launchFee.mul(100-sale_details.coupon).div(100) : sale_details.launchFee.mul(75).div(100);

        payable(admin).transfer(restartFee);

        sale_info[_round].start = _start;
        sale_info[_round].end = _end;
        sale_info[_round].attempt = sale_info[_round].attempt + 1;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}