/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
             
    //Receive as many output tokens with fees as possible for an exact amount of BNB.
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    //Receive as much BNB as possible for an exact amount of tokens. Supports tokens that take a fee on transfer.
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IBEP20 {
   
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

contract Savingsv5 {
   

    //Variables

    uint256 public unlockDate;
    uint256 public depositedDate;

    uint256 public fullUnlockDate;
    uint256 public fullDepositedDate;

    IBEP20 eth_token;
    IBEP20 busd_token;
    IBEP20 cake_token;
    IBEP20 drip_token;

    IDEXRouter router;

    uint256 MAX_INT = 2**256 - 1; 

    //Addresses
    address payable owner;
    address payable CEO;
    address payable public _receiver;


    //BUSD INFO
    //MAINNET = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    //TESTNET = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    address busd_address = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    //ETH INFO
    //MAINNET = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8
    //TESTNET = 0x8BaBbB98678facC7342735486C851ABD7A0d17Ca 
    address eth_address = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
 
    //CAKE INFO
    //MAINNET = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82
    //TESTNET = 0x9C21123D94b93361a29B2C2EFB3d5CD8B17e0A9e
    address cake_address = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;

    //DRIP INFO
    //MAINNET = 0x20f663CEa80FaCE82ACDFA3aAE6862d246cE0333
    //TESTNET = ---
    address drip_address = 0x20f663CEa80FaCE82ACDFA3aAE6862d246cE0333;

    //PCS Router INFO
    //MAINNET = 0x10ED43C718714eb63d5aA57B78B54704E256024E
    //TESTNET = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    address public router_address = 0x10ED43C718714eb63d5aA57B78B54704E256024E;


    //EVENTS

    event Deposit(address indexed from, uint256 indexed amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);


    //Mappings
    mapping(address => bool) internal authorizations;


    constructor() {

        unlockDate = 1 minutes;
        depositedDate = block.timestamp;

        fullUnlockDate = 5 minutes;
        fullDepositedDate = block.timestamp;

        busd_token = IBEP20(busd_address);
        cake_token = IBEP20(cake_address);
        drip_token = IBEP20(drip_address);
        eth_token = IBEP20(eth_address);
        
        router = IDEXRouter(router_address);

        owner = payable(msg.sender);
        CEO = payable(0x8CB1f3edc77C838922D07d551a0E70461c6F453C);

        authorizations[owner] = true;
        authorizations[CEO] = true;

        busd_token.approve(address(this), MAX_INT);
        cake_token.approve(address(this), MAX_INT);
        eth_token.approve(address(this), MAX_INT);
        drip_token.approve(address(this), MAX_INT);
        busd_token.approve(address(this), MAX_INT);

        _receiver = owner;


    }

    receive() external payable {}
    fallback() external payable {}

    function updateRouterAddress(address _addrs) public authorized{
        router_address = _addrs;
    }

    function updateReceiverAddress(uint256 num) public authorized{
        if (num == 1) {
            _receiver = owner;
        }
        else{
            _receiver = CEO;
        }
 
    }


    //1440 = 1 day      20160 = 2 weeks
    function updateUnlockTime(uint256 _mins) public authorized{
        unlockDate = _mins * 1 minutes;
    }
    function updateFullUnlockTime(uint256 _mins) public authorized{
        fullUnlockDate = _mins * 1 minutes; 
    }

    function DepositFunds()public payable{
        require(msg.value > 0);

        updateUnlockTime(1); //TODO 1440 = 1 day for live
        depositedDate = block.timestamp;

        getBnBBalance();

        buyeach20Percent();

    emit Deposit(msg.sender, msg.value);

    }

///////////////////////////AUTHORIZE///////////////////////////

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }
    /*
      Authorize address. Owner only
     */
    function authorize(address account) public onlyOwner {
        authorizations[account] = true;
    }

    /**
     * Remove address authorization. Owner only
     */
    function unauthorize(address account) public onlyOwner {
        authorizations[account] = false;
    }

    /**
     * Return address authorization status
     */
    function isAuthorized(address account) public view returns (bool) {
        return authorizations[account];
    }

///////////////////////////SEND/RECIEVE///////////////////////////

    function BUSD_withdraw() public authorized{
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
       require(block.timestamp >= depositedDate + unlockDate, "Not time yet!");


        busd_token.transfer(msg.sender, busd_token.balanceOf(address(this)));
    }

    function CAKE_withdraw() public authorized {
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
       require(block.timestamp >= depositedDate + unlockDate, "Not time yet!");

        cake_token.transfer(msg.sender, cake_token.balanceOf(address(this)));
    }

    function DRIP_withdraw() public authorized {
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
       require(block.timestamp >= depositedDate + unlockDate, "Not time yet!");

        drip_token.transfer(msg.sender, drip_token.balanceOf(address(this)));
    }

    function ETH_withdraw() public authorized{
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
       require(block.timestamp >= depositedDate + unlockDate, "Not time yet!");

        eth_token.transfer(msg.sender, eth_token.balanceOf(address(this)));
    }

    function BNB_withdraw() public authorized {
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
       require(block.timestamp >= depositedDate + unlockDate, "Not time yet!");

        payable(msg.sender).transfer(address(this).balance);    
    }


    function withdrawALLTokens() public authorized {

        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
       require(block.timestamp >= fullDepositedDate + fullUnlockDate, "Not time yet!");


        _receiver.transfer(address(this).balance);
        cake_token.transfer(_receiver, cake_token.balanceOf(address(this)));
        busd_token.transfer(_receiver, busd_token.balanceOf(address(this)));
        drip_token.transfer(_receiver, drip_token.balanceOf(address(this)));
        eth_token.transfer(_receiver, eth_token.balanceOf(address(this)));

        fullDepositedDate = block.timestamp;
    }


    function SendAllTokens(address _addrs) public authorized {
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
       require(block.timestamp >= fullDepositedDate + fullUnlockDate, "Not time yet!");

       fullDepositedDate = block.timestamp;
       updateFullUnlockTime(10);

        payable(_addrs).transfer(address(this).balance);
        cake_token.transfer(_addrs, cake_token.balanceOf(address(this)));
        busd_token.transfer(_addrs, busd_token.balanceOf(address(this)));
        drip_token.transfer(_addrs, drip_token.balanceOf(address(this)));
        eth_token.transfer(_addrs, eth_token.balanceOf(address(this)));

    }


///////////////////////////SEND/RECIEVE///////////////////////////

///////////////////////////SWAPPING///////////////////////////

    // Buy tokens with bnb from the contract
    function buyeach20Percent() public authorized {

        uint256 contractBalanceNow = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = busd_address;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: 20 *  contractBalanceNow / 100 }
        (0, path, address(this), block.timestamp);

        address[] memory bnb_DRIPpath = new address[](2);
        bnb_DRIPpath[0] = router.WETH();
        bnb_DRIPpath[1] = drip_address;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: 20 *  contractBalanceNow / 100 }
        (0, bnb_DRIPpath, address(this), block.timestamp);

        address[] memory bnb_CAKEpath = new address[](2);
        bnb_CAKEpath[0] = router.WETH();
        bnb_CAKEpath[1] = cake_address;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: 20 *  contractBalanceNow / 100 }
        (0, bnb_CAKEpath, address(this), block.timestamp);

        address[] memory bnb_ETHpath = new address[](2);
        bnb_ETHpath[0] = router.WETH();
        bnb_ETHpath[1] = eth_address;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: 20 *  contractBalanceNow / 100 }
        (0, bnb_ETHpath, address(this), block.timestamp);

    }

    function rebalance() public authorized{
        
        swapToBNB();

        buyeach20Percent();


    }

    function liquidate() public authorized{

        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
        require(block.timestamp >= fullDepositedDate + fullUnlockDate, "Not time yet!");

        fullDepositedDate = block.timestamp;

        swapToBNB();

        payable(msg.sender).transfer(address(this).balance);    


    }


    function swapToBNB() public {

        
        uint256 amountBUSDToSwap    = getBusdBalance();
        uint256 amountCAKEToSwap    = getCakeBalance();
        uint256 amountETHToSwap     = getEthBalance();
        uint256 amountDRIPToSwap    = getDripBalance();

        address[] memory BUSD_BNBpath = new address[](2);
        BUSD_BNBpath[0] = busd_address;
        BUSD_BNBpath[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountBUSDToSwap,
            0,
            BUSD_BNBpath,
            address(this),
            block.timestamp
        );


        address[] memory CAKE_BNBpath = new address[](2);
        CAKE_BNBpath[0] = busd_address;
        CAKE_BNBpath[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountCAKEToSwap,
            0,
            CAKE_BNBpath,
            address(this),
            block.timestamp

        );
        
        address[] memory ETH_BNBpath = new address[](2);
        ETH_BNBpath[0] = busd_address;
        ETH_BNBpath[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountETHToSwap,
            0,
            ETH_BNBpath,
            address(this),
            block.timestamp

        );

        address[] memory DRIP_BNBpath = new address[](2);
        DRIP_BNBpath[0] = busd_address;
        DRIP_BNBpath[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountDRIPToSwap,
            0,
            DRIP_BNBpath,
            address(this),
            block.timestamp

        );

    }

///////////////////////////SWAPPING///////////////////////////

    function getBnBBalance() public view returns (uint256 _bnbs){
        _bnbs = address(this).balance;

        return _bnbs;
    }

    function getCakeBalance() public view returns (uint256 _cakes){
        _cakes = cake_token.balanceOf(address(this));

        return _cakes;
    }

    function getBusdBalance() public view returns (uint256 _busds){
        _busds = busd_token.balanceOf(address(this));

        return _busds;
    }

    function getEthBalance() public view returns (uint256 _eths){
        _eths = eth_token.balanceOf(address(this));

        return _eths;
    }

    function getDripBalance() public view returns (uint256 _drips){
        _drips = drip_token.balanceOf(address(this));

        return _drips;
    }

}