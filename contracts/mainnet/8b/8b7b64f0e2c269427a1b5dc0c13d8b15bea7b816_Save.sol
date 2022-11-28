/**
 *Submitted for verification at BscScan.com on 2022-11-28
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

        unlockDate = 1440 minutes;
        depositedDate = block.timestamp;

        fullUnlockDate    = 20160 minutes;
        fullDepositedDate = block.timestamp;

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

    function DepositFunds()public payable{
        require(msg.value > 0);

        unlockDate = 1440; // 1 day in minutes
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

        depositedDate = block.timestamp;
        unlockDate = 1440 minutes;
    }

    function CAKE_withdraw() public authorized {
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
       require(block.timestamp >= depositedDate + unlockDate, "Not time yet!");

        cake_token.transfer(msg.sender, cake_token.balanceOf(address(this)));

        depositedDate = block.timestamp;
        unlockDate = 1440 minutes;
    }

    function DRIP_withdraw() public authorized {
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
       require(block.timestamp >= depositedDate + unlockDate, "Not time yet!");

        drip_token.transfer(msg.sender, drip_token.balanceOf(address(this)));

        depositedDate = block.timestamp;
        unlockDate = 1440 minutes;
    }

    function ETH_withdraw() public authorized{
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
       require(block.timestamp >= depositedDate + unlockDate, "Not time yet!");

        eth_token.transfer(msg.sender, eth_token.balanceOf(address(this)));
    
        depositedDate = block.timestamp;
        unlockDate = 1440 minutes;
    }

    function BNB_withdraw() public authorized {
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
       require(block.timestamp >= depositedDate + unlockDate, "Not time yet!");

        payable(msg.sender).transfer(address(this).balance); 

        depositedDate = block.timestamp;
        unlockDate = 1440 minutes;   
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
        fullUnlockDate    = 20160 minutes;
    }

    function SendAllTokens(address _addrs) public authorized {
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
       require(block.timestamp >= fullDepositedDate + fullUnlockDate, "Not time yet!");



        payable(_addrs).transfer(address(this).balance);
        cake_token.transfer(_addrs, cake_token.balanceOf(address(this)));
        busd_token.transfer(_addrs, busd_token.balanceOf(address(this)));
        drip_token.transfer(_addrs, drip_token.balanceOf(address(this)));
        eth_token.transfer(_addrs, eth_token.balanceOf(address(this)));

       fullDepositedDate = block.timestamp;
       fullUnlockDate    = 20160 minutes;

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



///////////////////////////SWAPPING///////////////////////////

}