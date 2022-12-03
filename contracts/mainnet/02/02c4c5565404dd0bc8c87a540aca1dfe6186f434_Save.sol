/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IDEXRouter {

    function WETH() external pure returns (address);
        
    //BNB to Token SWAP
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    //Token to BNB SWAP
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

interface IBEP20 {
   
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}


contract Save {

    //Variables

    uint256 public shortUnlockLength;
    uint256 public shortDepositedDate;

    uint256 public fullUnlockLength;
    uint256 public fullDepositedDate;

    IBEP20 eth_token;
    IBEP20 busd_token;
    IBEP20 cake_token;
    IBEP20 drip_token;

    IDEXRouter router;


    //Addresses
    address payable owner;
    address payable CEO;

    address public busd_address = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    
    address public eth_address = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
    
    address public  cake_address = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    
    address public drip_address = 0x20f663CEa80FaCE82ACDFA3aAE6862d246cE0333;
    

    address public router_address = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    //EVENTS
    event Deposit(address indexed from, uint256 indexed amount);
    event BusdApproval(address indexed owner, address indexed spender, uint256 value);
    event ETHApproval(address indexed owner, address indexed spender, uint256 value);
    event CAKEApproval(address indexed owner, address indexed spender, uint256 value);
    event DRIPApproval(address indexed owner, address indexed spender, uint256 value);


    //Mappings
    mapping(address => bool) internal authorizations;

    constructor() {

        //Set Router
        router = IDEXRouter(router_address);

        //Set Tokens
        busd_token = IBEP20(busd_address);
        cake_token = IBEP20(cake_address);
        drip_token = IBEP20(drip_address);
        eth_token = IBEP20(eth_address);
        
        //Owner
        owner = payable(msg.sender);
        CEO = payable(0x8CB1f3edc77C838922D07d551a0E70461c6F453C);

        authorizations[owner] = true;
        authorizations[CEO] = true;


        shortUnlockLength = 1440 minutes;
        shortDepositedDate = block.timestamp;

        fullUnlockLength    = 20160 minutes;
        fullDepositedDate = block.timestamp;

    }

    receive() external payable {

    emit Deposit(msg.sender, msg.value);

    }
    fallback() external payable {

    }

    function updateRouterAddress(address _addrs) public authorized{
        router_address = _addrs;
    }

    //1440 (minutes) = 1 day      20160 (minutes) = 2 weeks

    function DepositFunds()public payable{

        if(block.timestamp >= fullDepositedDate + fullUnlockLength) {
            
            require(msg.value > 0);

            fullDepositedDate = block.timestamp;
            fullUnlockLength    = 20160 minutes;

            shortUnlockLength = 1440 minutes; // 1 day in minutes
            shortDepositedDate = block.timestamp;

            getBnBBalance();

            buyeach20Percent();

            emit Deposit(msg.sender, msg.value);


        } else {
            require(msg.value > 0);

            shortUnlockLength = 1440 minutes; // 1 day in minutes
            shortDepositedDate = block.timestamp;

            getBnBBalance();

            buyeach20Percent();

            emit Deposit(msg.sender, msg.value);
        }


        require(msg.value > 0);

        shortUnlockLength = 1440 minutes; // 1 day in minutes
        shortDepositedDate = block.timestamp;

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

    modifier noZero() {
        require(msg.sender != address(0), "Request must not originate from a zero account");
        _;
    }

    modifier shortUnlocked() {
       require(block.timestamp >= shortDepositedDate + shortUnlockLength, "Not time yet!");
        _;
    }

    function BUSD_withdraw() public authorized shortUnlocked noZero{

        busd_token.transfer(msg.sender, busd_token.balanceOf(address(this)));

        shortDepositedDate = block.timestamp;
        shortUnlockLength = 1440 minutes;
    }

    function CAKE_withdraw() public authorized shortUnlocked noZero{

        cake_token.transfer(msg.sender, cake_token.balanceOf(address(this)));

        shortDepositedDate = block.timestamp;
        shortUnlockLength = 1440 minutes;
    }

    function DRIP_withdraw() public authorized shortUnlocked noZero{


        drip_token.transfer(msg.sender, drip_token.balanceOf(address(this)));

        shortDepositedDate = block.timestamp;
        shortUnlockLength = 1440 minutes;
    }

    function ETH_withdraw() public authorized shortUnlocked noZero{


        eth_token.transfer(msg.sender, eth_token.balanceOf(address(this)));
    
        shortDepositedDate = block.timestamp;
        shortUnlockLength = 1440 minutes;
    }

    function BNB_withdraw() public authorized shortUnlocked noZero{


        payable(msg.sender).transfer(address(this).balance); 

        shortDepositedDate = block.timestamp;
        shortUnlockLength = 1440 minutes;   
    }


    modifier longUnlocked() {
       require(block.timestamp >= fullDepositedDate + fullUnlockLength, "Not time yet!");
        _;
    }

    function withdrawALLTokens() public authorized longUnlocked noZero{


        payable(msg.sender).transfer(address(this).balance);
        cake_token.transfer(msg.sender, cake_token.balanceOf(address(this)));
        busd_token.transfer(msg.sender, busd_token.balanceOf(address(this)));
        drip_token.transfer(msg.sender, drip_token.balanceOf(address(this)));
        eth_token.transfer(msg.sender, eth_token.balanceOf(address(this)));

    }

    function SendAllTokens(address _addrs) public authorized longUnlocked noZero{

        payable(_addrs).transfer(address(this).balance);
        cake_token.transfer(_addrs, cake_token.balanceOf(address(this)));
        busd_token.transfer(_addrs, busd_token.balanceOf(address(this)));
        drip_token.transfer(_addrs, drip_token.balanceOf(address(this)));
        eth_token.transfer(_addrs, eth_token.balanceOf(address(this)));

    }

    // Buy tokens with20% Each bnb from the contract
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

    function swapToBNB() public authorized {

 //SELL BUSD
        uint256 BUSDBalanceNow = busd_token.balanceOf(address(this));


        address[] memory BUSDpath = new address[](2);
        BUSDpath[0] = busd_address;
        BUSDpath[1] = router.WETH();

        busd_token.approve(router_address, BUSDBalanceNow);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens
        (BUSDBalanceNow, 0, BUSDpath, address(this), block.timestamp);


        emit BusdApproval(address(this), router_address, BUSDBalanceNow);

 //SELL ETH
        uint256 ETHBalanceNow = eth_token.balanceOf(address(this));


        address[] memory ETHpath = new address[](2);
        ETHpath[0] = eth_address;
        ETHpath[1] = router.WETH();

        eth_token.approve(router_address, ETHBalanceNow);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens
        (ETHBalanceNow, 0, ETHpath, address(this), block.timestamp);


        emit ETHApproval(address(this), router_address, ETHBalanceNow);




 //SELL CAKE
        uint256 CAKEBalanceNow = cake_token.balanceOf(address(this));


        address[] memory CAKEpath = new address[](2);
        CAKEpath[0] = cake_address;
        CAKEpath[1] = router.WETH();

        cake_token.approve(router_address, CAKEBalanceNow);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens
        (CAKEBalanceNow, 0, CAKEpath, address(this), block.timestamp);


        emit CAKEApproval(address(this), router_address, CAKEBalanceNow);




 //SELL DRIP
        uint256 DRIPBalanceNow = drip_token.balanceOf(address(this));


        address[] memory DRIPpath = new address[](2);
        DRIPpath[0] = drip_address;
        DRIPpath[1] = router.WETH();

        drip_token.approve(router_address, DRIPBalanceNow);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens
        (DRIPBalanceNow, 0, DRIPpath, address(this), block.timestamp);


        emit DRIPApproval(address(this), router_address, DRIPBalanceNow);


    }

    function liquidate() public authorized longUnlocked noZero{

        swapToBNB();

        payable(msg.sender).transfer(address(this).balance); 


    }

    function rebalance() public authorized {

        swapToBNB();

        buyeach20Percent();

    }

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