/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.10;


interface IBEP20 {
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

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}

contract BTD_MINER {
    address public btdAddress = 0x7Cc648054aBDC545AFEB53EF30ad4eF0F58e1B8B; 

    uint256 public PAY_AMOUNT = 10000000000000000;
    uint256 public BTD_TO_HATCH_1MINERS=86400;//for final version should be seconds in a day

    bool public initialized=false;

    address public ceoAddress;
    address public ceoAddress2;
    address public stakeLpAddress = 0x197f6813D4D1F542f64976Aa14f177941FBE219e;

    mapping (address => uint256) public unpaidedBtd;

    mapping (address => uint256) public lastCliamed;
    mapping (address => uint256) public lastHatched;
    mapping (address => uint256) public lastHatchedPrice;

    mapping (address => address) public referrals;

    mapping (address => uint256) public son;  
    mapping (address => uint256) public grandsons;

    constructor() {
        ceoAddress=msg.sender;
        ceoAddress2=address(0xB7533cca87a83EE2cB8a2B2Cb214d99f54ADd275);
    }

    receive() external payable {}

    function hatchBTD(address ref) public payable {
        require(initialized,"miner not open");
        require(msg.value == PAY_AMOUNT,"only accept 0.01");

        takeFee();

        if(ref == msg.sender) {
            ref = address(0);
        }
        if(referrals[msg.sender]==address(0) && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;

            //increase son count is father exist.
            if(ref != address(0)){
                son[ref] = son[ref] + 1;
            }

            //increase grandsons count if grandfather exist.
            if( ref != address(0) && referrals[ref]!=address(0)){
                grandsons[referrals[ref]] = grandsons[referrals[ref]] + 1;
            }
        }

        //if not claimed. add to claimed to record.
        if(lastHatched[msg.sender] > lastCliamed[msg.sender]){
            unpaidedBtd[msg.sender] = getMyBTD(msg.sender);
        }else{
            unpaidedBtd[msg.sender]=0;
        }

        //remember last hatch time.
        lastHatched[msg.sender] = block.timestamp;
    }

    function claimBTD() public payable {
        require(initialized,"miner not open");
        require(msg.value == PAY_AMOUNT,"only accept 0.01");
        require(lastHatched[msg.sender] > 0,"please hatch first");

        takeFee();

        uint256 hasBTD=getMyBTD(address(msg.sender));
        if(hasBTD > 0){
            IBEP20(btdAddress).transfer(address(msg.sender),hasBTD);
        }

        unpaidedBtd[msg.sender]=0;
        lastCliamed[msg.sender]=block.timestamp;
    }


    function getMyBTD(address adr) public view returns(uint256) {
        return SafeMath.add(unpaidedBtd[adr],getBTDSinceLastHatch(adr));
    }
    function getBTDSinceLastHatch(address adr) public view returns(uint256) {
        if(lastHatched[adr] < lastCliamed[adr]){
            return 0;
        }
        uint256 secondsPassed=min(BTD_TO_HATCH_1MINERS, SafeMath.sub(block.timestamp, lastHatched[adr]));
        uint256 price = getPrice(adr);
        return price * secondsPassed / BTD_TO_HATCH_1MINERS;
    }

    function getPrice(address adr) public view returns (uint256){
        uint256 baseAmount = getBasePrice();

        uint256 addition = 0;
        if(son[adr] > 0){
            addition = addition +son[adr] * 2;
        }

        if(grandsons[adr] > 0){
            addition = addition +grandsons[adr] * 1;
        }

        addition =min(baseAmount, baseAmount * addition/100);

        return baseAmount + addition;
    }

    function getBasePrice() public  view returns (uint256){
        uint256 btdAmount = IBEP20(btdAddress).balanceOf(address(this));

        if(btdAmount > 60000000 * 1e18){
            return 200* 1e9;
        }else if(btdAmount > 50000000 * 1e18){
            return 150 * 1e9;
        }else if(btdAmount > 40000000 * 1e18){
            return 100 * 1e9;
        }else if(btdAmount > 30000000 * 1e18){
            return 50 * 1e9;
        }else if(btdAmount > 20000000 * 1e18){
            return 30 * 1e9;
        }else if(btdAmount > 10000000 * 1e18){
            return 20 * 1e9;
        }
            
        return 10 * 1e9;
    }

    function takeFee() internal {
        //0.005 to lp stake pool 
        uint256 stakeLpFee = PAY_AMOUNT/2; //0.005

        //0.001 to father refer is exist
        address fatherAddr = referrals[msg.sender];
        uint256 fatherFee = fatherAddr != address(0) ? PAY_AMOUNT/10 : 0; //0.001

        //0.005 to grandfather refer if exist.
        address grandfatherAddr = address(0);
        uint256 grandfatherFee =0;
        if(fatherAddr!=address(0) && referrals[fatherAddr]!=address(0)){
            grandfatherAddr = referrals[fatherAddr];
            grandfatherFee = PAY_AMOUNT/20 ; //0.0005
        }

        //the left to market.
        uint256 marketFee = PAY_AMOUNT - stakeLpFee - fatherFee - grandfatherFee;

        //transfer
        TransferHelper.safeTransferETH(stakeLpAddress, stakeLpFee);
        if(fatherFee > 0){
            TransferHelper.safeTransferETH(fatherAddr,fatherFee);
        }
        if(grandfatherFee > 0 ){
            TransferHelper.safeTransferETH(grandfatherAddr,grandfatherFee);
        }
        TransferHelper.safeTransferETH(ceoAddress2,marketFee);
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function startMiner() public {
        require(msg.sender == ceoAddress,"only ceo");
        initialized=true;
    }

    function setTokenAddr(address token) public {
        require(msg.sender == ceoAddress,"only ceo");
        btdAddress=token;
    }

    function withdrawBNB(uint256 amountOut) public payable {
        require(msg.sender == ceoAddress,"only ceo");
        TransferHelper.safeTransferETH(msg.sender, amountOut);
    }

    function withdrawToken(address token,uint256 amountOut) public payable {
        require(msg.sender == ceoAddress,"only ceo");
        TransferHelper.safeTransfer(token, msg.sender, amountOut);
    }
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}