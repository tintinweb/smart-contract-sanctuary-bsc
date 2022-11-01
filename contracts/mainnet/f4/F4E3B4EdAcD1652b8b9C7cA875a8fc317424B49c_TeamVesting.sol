/**
 *Submitted for verification at BscScan.com on 2022-11-01
*/

// SPDX-License-Identifier: MIT
/*
                                                                                          
                                 .!-)\^               >\[<:                               
                                 '/tttt:             ?tttt)                               
                                 '/ttttt:          .]ttttt1                               
                                 '/tttttti^",,,,""^)tttttt}                               
                  .              ^tttttttttttttttttttttttt{.             .                
                .l//_".      ':?/ttttttttttttttttttttttttttt1!^.      ',[/}^              
                ~tttttt);''!|tttttttttttttttttttttttttttttttttt/?".`i|ttttt/'             
                 :tttttttttttttttttttttttttttttttttttttttttttttttttttttttt|'              
                  "/ttttttttttttttttt\]i,^`'''.''`^";+)tttttttttttttttttt{.               
                   '|tttttttttttt/~"'                  .`;1ttttttttttttt~                 
                  .<ttttttttttt-^.                         'l\tttttttttt)`                
                 .1ttttttttt/<'                               ")tttttttttt;               
                '|ttttttttt?'            '^:l><>!:"'.           :/tttttttttl              
       `^``````^\tttttttt/:          ':]/tttttttttt)"            '{ttttttttt;''''````.    
      '/tttttttttttttttt/`         `?tttttttttttt)"               .[ttttttttttttttttti    
      ,\tttttttttttttttt"         >tttttttttttt)"                  .{tttttttttttttttt(.   
        `:?/ttttttttttt_        .]ttttttttttt)"            `.       '/ttttttttttt\+,'     
           .`_tttttttt/'        -tttttttttt/"            '-t]        +tttttttt/;`         
             :tttttttt(        '/tttttttttt~           '-ttt/`       "tttttttt/.          
             >tttttttt_        "ttttttttttt/,.       `_/ttttt;       '/ttttttt/.          
             >tttttttt_        "ttttttttttttt\:    '-tttttttt,       '/ttttttt/.          
             :tttttttt|        ./tttttttttttttt\?+1ttttttttt/.       "tttttttt/           
           ':{tttttttt/`      .I/ttttttttttttttttttttttttttt:        ?tttttttt/I`         
       .^<|tttttttttttt_     ,\tttttttttttttttttttttttttttt!        `/ttttttttttt/+".     
      Itttttttttttttt|:.  .:\tttttttttttttttttttttttttttt(^        .1tttttttttttttttt{    
      ./ttttttttttt\:   .;\tttttttttttttttttttttttttttt{"         .1tttttttttttttttttI    
       .''''...`|\:.   ,\ttttttttttttttttt/ttttttt/|+,'          ')ttttttttt:'''''```.    
                ..  .:\ttttttttttttttttt+` .'```''.            .;/ttttttttt;              
                  .;\ttttttttttttttttt-'                     .,|ttttttttt/,               
                .:\ttttttttttttttttt+'                     `>/tttttttttt}'                
              .I/ttttttttttttttttt~'                   '"<\ttttttttttttt<                 
             ,\ttttttttttttttttt-'   '<_I,^`''''``":i[/tttttttttttttttttt[.               
          .:\ttttttttttttttttt+'   '>/tttttttttttttttttttttttttttttttttttt)'              
        .;\ttttttttttttttttt-'   '_tttttttttttttttttttttttttttt\>`.`l|ttttt\'             
       ,\ttttttttttttttttt]'   .</tttttttttttttttttttttttttt};`       ':1/[`              
    .:\ttttttttttttttttt+`       "/ttttttttttttttttttttttt_.             .                
    (ttttt;''<tttttttt-'         `tttttt/,`^""""^^^|tttttt<                               
    .I/tt/'  "/ttttt+'           ^ttttt\`          .}ttttt+                               
      .;/tt|\ttttt~'             ^tttt\`            .[tttt_                               
        .l/ttttt-'               ';+{1'              .-|?i^                               
          .I//+'                                                                          
             .                                                                            
                                                                                          
by DeFi LABS
*/

pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;
    bool private _initializing;
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");
        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TeamVesting is Context, Initializable {
    address public _owner;
    address public dogewhale;

    address public dev;
    address public web3;
    address public marketeer;
    address public artist;

    uint256 public launch;
    uint256 public month3;
    uint256 public month6;
    uint256 public month9;
    uint256 public month12;

    bool public devClaim6Month;
    bool public devClaim12Month;
    bool public web3Claim6Month;
    bool public web3Claim12Month;
    bool public marketeerClaim3Month;
    bool public marketeerClaim6Month;
    bool public marketeerClaim12Month;
    bool public artistClaim3Month;
    bool public artistClaim6Month;
    bool public artistClaim12Month;

    function init() external initializer {
        _owner = 0x16f7c37FF84a71a8be7EB24228Cdc8E438D12060;
        dogewhale = 0x43adC41cf63666EBB1938B11256f0ea3f16e6932;

        dev = 0xC6E255CaFcDF7111D376904EdC0845C0914Ee678;
        web3 = 0x04515EDCE30562b0fA0F2d9971FA15A2e7724Df6;
        marketeer = 0xdF3836A2287D41ED716e841F6b9FB6a858575d7D;
        artist = 0x5d7d054a9F7660556cEa0788C07e1794b49e58Ff;

        launch = 1639515600;
        month3 = launch+(2629743*3);
        month6 = launch+(2629743*6);
        month12 = launch+(2629743*12);
    }

    //Marketing addy update - @purple swan
    function setMarketing() public virtual returns (bool) {
        require (msg.sender == _owner, "unable");
        marketeer = 0x13fAbA770DBE43167324D3e64a3FA2212c072521;
        web3 = 0xC6E255CaFcDF7111D376904EdC0845C0914Ee678;
        return true;
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    // VIEW VESTING  ===============================================================================>
    /////////////////////////////////////////////////////////////////////////////////////////////////
    function isMonth3Ready() public view returns (bool) {
        if (block.timestamp > month3) {
            return true;
        } else {
            return false;
        }
    }

    function isMonth6Ready() public view returns (bool) {
        if (block.timestamp > month6) {
            return true;
        } else {
            return false;
        }
    }

    function isMonth12Ready() public view returns (bool) {
        if (block.timestamp > month12) {
            return true;
        } else {
            return false;
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    // DEV VESTING  ================================================================================>
    /////////////////////////////////////////////////////////////////////////////////////////////////

    // 6 months post-launch
    function devVesting6Month() public virtual returns (bool) {
        require (block.timestamp > month6, "Not Yet");
        require (devClaim6Month == false, "Already Claimed");
        IERC20(dogewhale).transfer(dev, 1*10**28);
        devClaim6Month = true;
        return true;
    }

    // 12 months post-launch
    function devVesting12Month() public virtual returns (bool) {
        require (block.timestamp > month12, "Not Yet");
        require (devClaim12Month == false, "Already Claimed");
        IERC20(dogewhale).transfer(dev, 1*10**28);
        devClaim12Month = true;
        return true;
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    // WEB3 VESTING  ===============================================================================>
    /////////////////////////////////////////////////////////////////////////////////////////////////

    // 6 months post-launch
    function web3Vesting6Month() public virtual returns (bool) {
        require (block.timestamp > month6, "Not Yet");
        require (web3Claim6Month == false, "Already Claimed");
        IERC20(dogewhale).transfer(web3, 1*10**28);
        web3Claim6Month = true;
        return true;
    }

    // 12 months post-launch
    function web3Vesting12Month() public virtual returns (bool) {
        require (block.timestamp > month12, "Not Yet");
        require (web3Claim12Month == false, "Already Claimed");
        IERC20(dogewhale).transfer(web3, 1*10**28);
        web3Claim12Month = true;
        return true;
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    // MARKETEER VESTING  ==========================================================================>
    /////////////////////////////////////////////////////////////////////////////////////////////////

    // 3 months post-launch
    function marketeerVesting3Month() public virtual returns (bool) {
        require (block.timestamp > month3, "Not Yet");
        require (marketeerClaim3Month == false, "Already Claimed");
        IERC20(dogewhale).transfer(marketeer, 25*10**26);
        marketeerClaim3Month = true;
        return true;
    }

    // 6 months post-launch
    function marketeerVesting6Month() public virtual returns (bool) {
        require (block.timestamp > month6, "Not Yet");
        require (marketeerClaim6Month == false, "Already Claimed");
        IERC20(dogewhale).transfer(marketeer, 25*10**26);
        marketeerClaim6Month = true;
        return true;
    }

    // 12 months post-launch
    function marketeerVesting12Month() public virtual returns (bool) {
        require (block.timestamp > month12, "Not Yet");
        require (marketeerClaim12Month == false, "Already Claimed");
        IERC20(dogewhale).transfer(marketeer, 25*10**26);
        marketeerClaim12Month = true;
        return true;
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    // ARTIST VESTING  =============================================================================>
    /////////////////////////////////////////////////////////////////////////////////////////////////

    // 3 months post-launch
    function artistVesting3Month() public virtual returns (bool) {
        require (block.timestamp > month3, "Not Yet");
        require (artistClaim3Month == false, "Already Claimed");
        IERC20(dogewhale).transfer(artist, 25*10**26);
        artistClaim3Month = true;
        return true;
    }

    // 6 months post-launch
    function artistVesting6Month() public virtual returns (bool) {
        require (block.timestamp > month6, "Not Yet");
        require (artistClaim6Month == false, "Already Claimed");
        IERC20(dogewhale).transfer(artist, 25*10**26);
        artistClaim6Month = true;
        return true;
    }

    // 12 months post-launch
    function artistVesting12Month() public virtual returns (bool) {
        require (block.timestamp > month12, "Not Yet");
        require (artistClaim12Month == false, "Already Claimed");
        IERC20(dogewhale).transfer(artist, 25*10**26);
        artistClaim12Month = true;
        return true;
    }
}