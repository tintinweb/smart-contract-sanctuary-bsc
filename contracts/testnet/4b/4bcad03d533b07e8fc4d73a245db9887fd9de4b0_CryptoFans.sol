/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.0;
pragma abicoder v2;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract CryptoFans {

    address private owner;
    
    address private commisionOwner;
    uint256 private commissionPercentage;

    address private tokenBusd;
    address private tokenUsdt;

    mapping(address=>mapping(address=>mapping(uint256=>uint256))) public publicationAmountBusd; //usuario-> vendedor -> idpublicacion -> saldo _agado
    mapping(address=>mapping(address=>mapping(uint256=>uint256))) public publicationDateBusd; //usuario-> vendedor -> idpublicacion -> fecha _agado
    
    mapping(address=>mapping(address=>mapping(uint256=>uint256))) public publicationAmountUsdt; //usuario-> vendedor -> idpublicacion -> saldo _agado
    mapping(address=>mapping(address=>mapping(uint256=>uint256))) public publicationDateUsdt; //usuario-> vendedor -> idpublicacion -> fecha _agado

    mapping(address=>uint256) public collectedBusd;
    mapping(address=>uint256) public collectedUsdt;

    mapping(address=>uint256) public collectedCommisionBusd;
    mapping(address=>uint256) public collectedCommisionUsdt;

    uint256 public collectedCommisionTotalBusd;
    uint256 public collectedCommisionTotalUsdt;


    modifier isOwner() {
        require(msg.sender == owner, "owner no _resente");
        _;
    }
    constructor(){
        owner = msg.sender; 

    }
    function init(address _tokenBusd, address _tokenUsdt, address _commisionOwner, uint256 _commissionPercentage) public isOwner {
        tokenBusd = _tokenBusd;
        tokenUsdt = _tokenUsdt;
        commisionOwner = _commisionOwner;
        commissionPercentage = _commissionPercentage;

    }

    function setCommisionOwner(address _commisionOwner) public isOwner {
        commisionOwner = _commisionOwner;
    }
    
    function setCommissionPercentage(uint256 _commissionPercentage) public isOwner {
        commissionPercentage = _commissionPercentage;
    }

    
    function setTokenBusd(address _tokenBusd) public isOwner {
        tokenBusd = _tokenBusd;
    }

    function setTokenUsdt(address _tokenUsdt) public isOwner {
        tokenUsdt = _tokenUsdt;
    }

    function collectMoneyBusd(address _vendedor, uint256 publicacion, uint256 _amount) public {

        IERC20 TOKEN = IERC20(tokenBusd);
        require(TOKEN.balanceOf(msg.sender) >= ((_amount * 1e18)), "SALDO INSUFICIENTE");
        require(TOKEN.allowance(msg.sender, address(this)) >= (_amount * 1e18),"SALDO APROBADO INSUFICIENTE");

        require(TOKEN.transferFrom(msg.sender, commisionOwner, ((_amount * 1e18)/commissionPercentage)),"transfer Error");
        require(TOKEN.transferFrom(msg.sender, _vendedor, ((_amount * 1e18)-((_amount * 1e18)/commissionPercentage))),"transfer Error");

        collectedCommisionTotalBusd+=((_amount * 1e18)/commissionPercentage);
        collectedCommisionBusd[commisionOwner]+=((_amount * 1e18)/commissionPercentage);
        collectedBusd[_vendedor]+=((_amount * 1e18)-((_amount * 1e18)/commissionPercentage));

        publicationAmountBusd[msg.sender][_vendedor][publicacion] += _amount; 
        publicationDateBusd[msg.sender][_vendedor][publicacion] = block.timestamp;  
    }

    function collectMoneyUsdt(address _vendedor, uint256 publicacion, uint256 _amount) public {

        IERC20 TOKEN = IERC20(tokenUsdt);
        require(TOKEN.allowance(msg.sender, address(this)) >= (_amount * 1e18),"SALDO APROBADO INSUFICIENTE");
        require(TOKEN.balanceOf(msg.sender) >= ((_amount * 1e18)), "SALDO INSUFICIENTE");
        
        require(TOKEN.transferFrom(msg.sender, commisionOwner, ((_amount * 1e18)/commissionPercentage)),"transfer Error");
        require(TOKEN.transferFrom(msg.sender, _vendedor, ((_amount * 1e18)-((_amount * 1e18)/commissionPercentage))),"transfer Error");

        collectedCommisionTotalUsdt+=((_amount * 1e18)/commissionPercentage);
        collectedCommisionUsdt[commisionOwner]+=((_amount * 1e18)/commissionPercentage);
        collectedUsdt[_vendedor]+=((_amount * 1e18)-((_amount * 1e18)/commissionPercentage));

        publicationAmountUsdt[msg.sender][_vendedor][publicacion] += _amount; 
        publicationDateUsdt[msg.sender][_vendedor][publicacion] = block.timestamp;  
    }

    function getBusdBal() public view returns (uint256) {
        return IERC20(tokenBusd).balanceOf(msg.sender);
    }

    function getUsdTBal() public view returns (uint256) {
        return IERC20(tokenBusd).balanceOf(msg.sender);
    }


}