/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    //Adds liquidity to a BEP20⇄BEP20 pool.
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

             
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
   
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);


}

contract Savings {

    address payable owner;
    address payable CEO;

    IDEXRouter public bnb_token;
    IBEP20 public wbnb_token;
    IBEP20 public eth_token;
    IBEP20 public busd_token;
    IBEP20 public cake_token;
    IBEP20 public drip_token;

    IDEXRouter public router;

    uint256 MAX_INT = 2**256 - 1;

    //WBNB INFO
    //MAINNET = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    //TESTNET = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
    address public wbnb_address = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    //BUSD INFO
    //MAINNET = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    //TESTNET = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    address public busd_address = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    //ETH INFO
    //MAINNET = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8
    //TESTNET = 0x8BaBbB98678facC7342735486C851ABD7A0d17Ca 
    address public eth_address = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
 
    //CAKE INFO
    //MAINNET = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82
    //TESTNET = 0x9C21123D94b93361a29B2C2EFB3d5CD8B17e0A9e
    address public cake_address = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;

    address public router_address = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    //DRIP INFO
    //MAINNET = 0x20f663CEa80FaCE82ACDFA3aAE6862d246cE0333
    //TESTNET = ---
    address public drip_address = 0x20f663CEa80FaCE82ACDFA3aAE6862d246cE0333;

    address public CAKEBUSDLP;

    uint256 public lockTime = 2 minutes;
    uint256 public fullLockTime = 5 minutes;

    event bnbWithdrawal(address indexed to, uint256 indexed amount);
    event wbnbWithdrawal(address indexed to, uint256 indexed amount);
    event cakeWithdrawal(address indexed to, uint256 indexed amount);
    event ethWithdrawal(address indexed to, uint256 indexed amount);
    event dripWithdrawal(address indexed to, uint256 indexed amount);
    event busdWithdrawal(address indexed to, uint256 indexed amount);
    event Deposit(address indexed from, uint256 indexed amount);

    mapping(address => uint256) nextAccessTime;
    mapping(address => uint256) nextFullAccessTime;
    mapping(address => bool) internal authorizations;


    constructor() {


        wbnb_token = IBEP20(wbnb_address);
        busd_token = IBEP20(busd_address);
        cake_token = IBEP20(cake_address);
        drip_token = IBEP20(drip_address);
        eth_token = IBEP20(eth_address);


        //PCS Router INFO
        //MAINNET = 0x10ED43C718714eb63d5aA57B78B54704E256024E
        //TESTNET = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        
        router = IDEXRouter(router_address);

        owner = payable(msg.sender);
        CEO = payable(0x8CB1f3edc77C838922D07d551a0E70461c6F453C);

        authorizations[owner] = true;
        authorizations[CEO] = true;



    }

///////////////////////////AUTHORIZE///////////////////////////

    function approvAll() public authorized payable{

            IBEP20(wbnb_address).approve(router_address, MAX_INT);
            IBEP20(busd_address).approve(router_address, MAX_INT);
            IBEP20(cake_address).approve(router_address, MAX_INT);
            IBEP20(drip_address).approve(router_address, MAX_INT);
            IBEP20(eth_address).approve(router_address, MAX_INT);

    }


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

    event Approval(address indexed owner, address indexed spender, uint256 value);


    function BUSD_withdraw() public {
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
        require(
            busd_token.balanceOf(address(this)) > 0,
            "Insufficient balance in faucet for withdrawal request"
        );
        require(
            block.timestamp >= nextAccessTime[msg.sender],
            "Insufficient time elapsed since last withdrawal - try again later."
        );

        nextAccessTime[msg.sender] = block.timestamp + lockTime;

        busd_token.transfer(msg.sender, busd_token.balanceOf(address(this)));
    }

    function CAKE_withdraw() public {
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
        require(
            cake_token.balanceOf(address(this)) > 0,
            "Insufficient balance in faucet for withdrawal request"
        );
        require(
            block.timestamp >= nextAccessTime[msg.sender],
            "Insufficient time elapsed since last withdrawal - try again later."
        );

        nextAccessTime[msg.sender] = block.timestamp + lockTime;

        cake_token.transfer(msg.sender, cake_token.balanceOf(address(this)));
    }

    function DRIP_withdraw() public {
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
        require(
            drip_token.balanceOf(address(this)) > 0,
            "Insufficient balance in faucet for withdrawal request"
        );
        require(
            block.timestamp >= nextAccessTime[msg.sender],
            "Insufficient time elapsed since last withdrawal - try again later."
        );

        nextAccessTime[msg.sender] = block.timestamp + lockTime;

        drip_token.transfer(msg.sender, drip_token.balanceOf(address(this)));
    }

    function ETH_withdraw() public {
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
        require(
            eth_token.balanceOf(address(this)) > 0,
            "Insufficient balance in faucet for withdrawal request"
        );
        require(
            block.timestamp >= nextAccessTime[msg.sender],
            "Insufficient time elapsed since last withdrawal - try again later."
        );

        nextAccessTime[msg.sender] = block.timestamp + lockTime;

        eth_token.transfer(msg.sender, eth_token.balanceOf(address(this)));
    }

    function BNB_withdraw() public {
        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
        require(
            address(this).balance > 0,
            "Insufficient balance in faucet for withdrawal request"
        );
        require(
            block.timestamp >= nextAccessTime[msg.sender],
            "Insufficient time elapsed since last withdrawal - try again later."
        );

        nextAccessTime[msg.sender] = block.timestamp + lockTime;

        payable(msg.sender).transfer(address(this).balance);    
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
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

    //1440 Minutes in one day
    function setLockTime(uint256 amount) public onlyOwner {
        lockTime = amount * 1 minutes;
    }


    function setFullLockTime(uint256 amount) public onlyOwner {
        fullLockTime = amount * 1 minutes;
    }

    function withdrawALLTokens() public onlyOwner {

        require(
            msg.sender != address(0),
            "Request must not originate from a zero account"
        );
        require(
            address(this).balance > 0,
            "Insufficient balance in faucet for withdrawal request"
        );
        require(
            block.timestamp >= nextFullAccessTime[msg.sender],
            "Insufficient time elapsed since last withdrawal - try again later."
        );

        nextFullAccessTime[msg.sender] = block.timestamp + fullLockTime;

        emit bnbWithdrawal(msg.sender, address(this).balance);
        wbnb_token.transfer(msg.sender, wbnb_token.balanceOf(address(this)));

        emit wbnbWithdrawal(msg.sender, wbnb_token.balanceOf(address(this)));
        wbnb_token.transfer(msg.sender, wbnb_token.balanceOf(address(this)));

        emit cakeWithdrawal(msg.sender, cake_token.balanceOf(address(this)));
        cake_token.transfer(msg.sender, cake_token.balanceOf(address(this)));
        
        emit busdWithdrawal(msg.sender, busd_token.balanceOf(address(this)));
        busd_token.transfer(msg.sender, busd_token.balanceOf(address(this)));
    
        emit dripWithdrawal(msg.sender, drip_token.balanceOf(address(this)));
        drip_token.transfer(msg.sender, drip_token.balanceOf(address(this)));

        emit ethWithdrawal(msg.sender, eth_token.balanceOf(address(this)));
        eth_token.transfer(msg.sender, eth_token.balanceOf(address(this)));

    }

///////////////////////////SEND/RECIEVE///////////////////////////

///////////////////////////SWAPPING///////////////////////////




    // Buy amount of tokens with bnb from the contract
    function balance16Percent() public authorized {

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = busd_address;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: 20 *  getBnBBalance() / 100 }
        (0, path, address(this), block.timestamp);

        address[] memory bnb_DRIPpath = new address[](2);
        bnb_DRIPpath[0] = router.WETH();
        bnb_DRIPpath[1] = drip_address;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: 20 *  getBnBBalance() / 100 }
        (0, bnb_DRIPpath, address(this), block.timestamp);

        address[] memory bnb_CAKEpath = new address[](2);
        bnb_CAKEpath[0] = router.WETH();
        bnb_CAKEpath[1] = cake_address;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: 20 *  getBnBBalance() / 100 }
        (0, bnb_CAKEpath, address(this), block.timestamp);

        address[] memory bnb_ETHpath = new address[](2);
        bnb_ETHpath[0] = router.WETH();
        bnb_ETHpath[1] = eth_address;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: 20 *  getBnBBalance() / 100 }
        (0, bnb_ETHpath, address(this), block.timestamp);

    }

///////////////////////////SWAPPING///////////////////////////

}