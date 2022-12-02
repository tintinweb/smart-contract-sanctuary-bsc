/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    //Token to Token SWAP
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
        
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
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}


contract Save {

    //Variables

    uint256 public unlockLength;
    uint256 public fullUnlockLength;

    uint256 public depositedDate;
    uint256 public fullDepositedDate;

    IBEP20 wbnb_token;
    IBEP20 busd_token;
    IBEP20 eth_token;
    IBEP20 cake_token;
    IBEP20 drip_token;

    IDEXRouter router;


    //Addresses
    address payable owner;
    address payable CEO;

    address wbnb_address = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address busd_address = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    address eth_address = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
    
    address cake_address = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    
    address drip_address = 0x20f663CEa80FaCE82ACDFA3aAE6862d246cE0333;
    

    address public router_address = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    //EVENTS
    event Deposit(address indexed from, uint256 indexed amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    //Mappings
    mapping(address => bool) internal authorizations;

    constructor() {


        wbnb_token = IBEP20(wbnb_address);
        busd_token = IBEP20(busd_address);
        eth_token = IBEP20(eth_address);
        cake_token = IBEP20(cake_address);
        drip_token = IBEP20(drip_address);
        
        router = IDEXRouter(router_address);

        owner = payable(msg.sender);
        CEO = payable(0x8CB1f3edc77C838922D07d551a0E70461c6F453C);

        authorizations[owner] = true;
        authorizations[CEO] = true;



        unlockLength = 1440 minutes;
        depositedDate = block.timestamp;

        fullUnlockLength    = 20160 minutes;
        fullDepositedDate = block.timestamp;

    }

    receive() external payable {

        emit Deposit(msg.sender, msg.value);

    }
    fallback() external payable {


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


    function updateRouterAddress(address _addrs) public authorized{
        router_address = _addrs;
    }


///////////////////////////SEND/RECIEVE///////////////////////////

    //  1440 (minutes) = 1 day   
    // 20160 (minutes) = 2 weeks

    function DepositFunds()public payable{
        if (block.timestamp >= fullDepositedDate + fullUnlockLength) {

            fullDepositedDate = block.timestamp;
            fullUnlockLength    = 20160 minutes;

        require(msg.value > 0);

        unlockLength = 1440 minutes; // 1 day in minutes
        depositedDate = block.timestamp;

        getBnBBalance();

        balanceBuy();

    emit Deposit(msg.sender, msg.value);

        } else {        

        require(msg.value > 0);

        unlockLength = 1440 minutes; // 1 day in minutes
        depositedDate = block.timestamp;

        getBnBBalance();

        balanceBuy();

    emit Deposit(msg.sender, msg.value);

        }

    }

///////////////////SINGLE WITHDRAWALs////////////////////

    function BNB_withdraw() public authorized {
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
       require(block.timestamp >= depositedDate + unlockLength, "Not time yet!");

        payable(msg.sender).transfer(address(this).balance); 

        depositedDate = block.timestamp;
        unlockLength = 1440 minutes;   
    }
    
    function BUSD_withdraw() public authorized{
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
       require(block.timestamp >= depositedDate + unlockLength, "Not time yet!");

        busd_token.transfer(msg.sender, busd_token.balanceOf(address(this)));

        depositedDate = block.timestamp;
        unlockLength = 1440 minutes;
    }

    function ETH_withdraw() public authorized{
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
       require(block.timestamp >= depositedDate + unlockLength, "Not time yet!");

        eth_token.transfer(msg.sender, eth_token.balanceOf(address(this)));
    
        depositedDate = block.timestamp;
        unlockLength = 1440 minutes;
    }

    function CAKE_withdraw() public authorized {
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
       require(block.timestamp >= depositedDate + unlockLength, "Not time yet!");

        cake_token.transfer(msg.sender, cake_token.balanceOf(address(this)));

        depositedDate = block.timestamp;
        unlockLength = 1440 minutes;
    }

    function DRIP_withdraw() public authorized {
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
       require(block.timestamp >= depositedDate + unlockLength, "Not time yet!");

        drip_token.transfer(msg.sender, drip_token.balanceOf(address(this)));

        depositedDate = block.timestamp;
        unlockLength = 1440 minutes;
    }

/////////////////////FULL WITHDRAWALS//////////////////////////////


    function withdrawALLTokens() public authorized {

        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
       require(block.timestamp >= fullDepositedDate + fullUnlockLength, "Not time yet!");

        payable(msg.sender).transfer(address(this).balance);
        cake_token.transfer(msg.sender, cake_token.balanceOf(address(this)));
        busd_token.transfer(msg.sender, busd_token.balanceOf(address(this)));
        drip_token.transfer(msg.sender, drip_token.balanceOf(address(this)));
        eth_token.transfer(msg.sender, eth_token.balanceOf(address(this)));

        fullUnlockLength    = 20160 minutes;
    }

    function SendAllTokens(address _addrs) public authorized {
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
       require(block.timestamp >= fullDepositedDate + fullUnlockLength, "Not time yet!");

        payable(_addrs).transfer(address(this).balance);
        cake_token.transfer(_addrs, cake_token.balanceOf(address(this)));
        busd_token.transfer(_addrs, busd_token.balanceOf(address(this)));
        drip_token.transfer(_addrs, drip_token.balanceOf(address(this)));
        eth_token.transfer(_addrs, eth_token.balanceOf(address(this)));

       fullUnlockLength    = 20160 minutes;

    }

///////////////////////////SEND/RECIEVE///////////////////////////

///////////////////////////SWAPPING///////////////////////////

    // Buy tokens with bnb from the contract
    function balanceBuy() public authorized {

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


    function sellAllTokens() public authorized {

        _approveBusd();
        _approveEth();
        _approveCake();
        _approveDrip();

        uint256 BUSDTokenBalanceNow = busd_token.balanceOf(address(this));
        uint256 ETHTokenBalanceNow = eth_token.balanceOf(address(this));
        uint256 CAKETokenBalanceNow = cake_token.balanceOf(address(this));
        uint256 DRIPTokenBalanceNow = drip_token.balanceOf(address(this));

        address[] memory BUSDpath = new address[](2);
        BUSDpath[0] = busd_address;
        BUSDpath[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens
        (BUSDTokenBalanceNow, 0, BUSDpath, address(this), block.timestamp);

        address[] memory ETHpath = new address[](2);
        ETHpath[0] = eth_address;
        ETHpath[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens
        (ETHTokenBalanceNow, 0, ETHpath, address(this), block.timestamp);

        address[] memory CAKEpath = new address[](2);
        CAKEpath[0] = cake_address;
        CAKEpath[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens
        (CAKETokenBalanceNow, 0, CAKEpath, address(this), block.timestamp);

        address[] memory DRIPpath = new address[](2);
        DRIPpath[0] = drip_address;
        DRIPpath[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens
        (DRIPTokenBalanceNow, 0, DRIPpath, address(this), block.timestamp);

    }

    function _approveBusd() internal { 
        uint256 BUSDTokenBalanceNow = busd_token.balanceOf(address(this));
       
        busd_token.approve(address(this), BUSDTokenBalanceNow);
        emit Approval(address(this), router_address, BUSDTokenBalanceNow);
    }
    function _approveEth() internal {        
        uint256 ETHTokenBalanceNow = eth_token.balanceOf(address(this));

        eth_token.approve(address(this), ETHTokenBalanceNow);
        emit Approval(address(this), router_address, ETHTokenBalanceNow);
    }
    function _approveCake() internal {     
        uint256 CAKETokenBalanceNow = cake_token.balanceOf(address(this));
   
        cake_token.approve(address(this), CAKETokenBalanceNow);
        emit Approval(address(this), router_address, CAKETokenBalanceNow);
    }
    function _approveDrip() internal {   
        uint256 DRIPTokenBalanceNow = drip_token.balanceOf(address(this));
     
        drip_token.approve(address(this), DRIPTokenBalanceNow);
        emit Approval(address(this), router_address, DRIPTokenBalanceNow);
    }

    function liquidate() public authorized{
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
       require(block.timestamp >= fullDepositedDate + fullUnlockLength, "Not time yet!");

        sellAllTokens();

        payable(msg.sender).transfer(address(this).balance);


    }

    function rebalanceTokens() public authorized{

        sellAllTokens();

        balanceBuy();

    }
///////////////////////////SWAPPING///////////////////////////

////////////////////GETTERS///////////////////////////////////


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