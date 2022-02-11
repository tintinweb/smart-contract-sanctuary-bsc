/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

// SPDX-License-Identifier: MIT
// File: UsePay/UsePAY/Storage/WrapAddresses.sol


pragma solidity >= 0.7.0;

contract WrapAddresses {
    // address internal iAddresses = 0x30BafbA23f24d386a39210280590B0346c0dfd92; // UePAY_eth_rinkeby
    // address internal iAddresses = 0x31716bbA4B12A52592c041ED19Dc06B5F99e20e8; //UsePAY_bsc_testnet

    address internal iAddresses = 0x45EAD600FEe90dFfa542a42C236Daf76f343E842; // UsePAY_0203_bsc_testnet

    // address internal iAddresses = ; // UsePAY_eth_mainnet
    // address internal iAddresses = ; // UsePAY_bsc_mainnet


    // address internal iAddresses = 0x48aa9c47897B50dBF8B7dc3A1bFa4b05C481EB3d; //Bridge_eth_mainnet
    // address internal iAddresses = 0x48aa9c47897B50dBF8B7dc3A1bFa4b05C481EB3d; // Bridge_bsc_mainnet
    


    modifier onlyManager(address _addr) {
        checkManager(_addr);
        _;
    }
    
    function checkManager(address _addr) internal view {
        (, bytes memory result ) = address( iAddresses ).staticcall(abi.encodeWithSignature("checkManger(address)",_addr));
        require( abi.decode(result,(bool)) , "This address is not Manager");
    } 
}

// File: UsePay/UsePAY/Commander/BSC/BSC_Commander.sol


pragma solidity >= 0.7.0;
pragma experimental ABIEncoderV2;


contract Commander is WrapAddresses {
    
    event giftEvent(address indexed pack,address fromAddr ,address[] toAddr); // 0: pack indexed, 1: from, 2: to, 3: count
    event giveEvent(address indexed pack,address fromAddr ,address[] toAddr); // 0: pack indexed, 1: from, 2: to, 3: count
    
    
    function _transfer(uint8 tokenType, address _to , uint256 value ) internal {
        if ( tokenType == 100 ) {
            payable(_to).transfer(value);
        } else { 
            (bool success0,bytes memory tokenResult) = address(iAddresses).staticcall(abi.encodeWithSignature("viewAddress(uint16)",uint16(tokenType)));
            require(success0,"0");
            (bool success, ) = address(abi.decode(tokenResult,(address))).call(abi.encodeWithSignature("transfer(address,uint256)",_to,value));
            require(success,"TOKEN transfer Fail");
        }
    }

    function _getBalance(uint8 tokenType) internal view returns (uint256) {
        uint balance = 0;
        if ( tokenType ==  100  ) {
            balance = address(this).balance;
        } else {
            (,bytes memory tokenResult) = address(iAddresses).staticcall(abi.encodeWithSignature("viewAddress(uint16)",uint16(tokenType)));
            (,bytes memory result) = address(abi.decode(tokenResult,(address))).staticcall(abi.encodeWithSignature("balanceOf(address)",address(this)));
            balance = abi.decode(result,(uint256));
        }   
        return balance;
    }
    
    
    function _swap( address _to, uint256 amountIn ) internal returns (uint256) {
        (,bytes memory result0 ) = address(iAddresses).staticcall(abi.encodeWithSignature("viewAddress(uint16)",1200));
        (address routerAddr) = abi.decode(result0,(address));
        ( ,bytes memory resultDFM ) = address(iAddresses).staticcall(abi.encodeWithSignature("viewAddress(uint16)",101));
        // if ( _fromToken == address(0) ) {
            uint deadline = block.timestamp + 1000;
            address[] memory path = new address[](2);
            (, bytes memory resultWETH) = address(iAddresses).staticcall(abi.encodeWithSignature("viewAddress(uint16)",uint16(103)));
            path[0] = abi.decode(resultWETH,(address));
            path[1] = abi.decode(resultDFM,(address));
            (bool success, bytes memory result) = address( routerAddr ).call{ value: amountIn }(abi.encodeWithSignature("swapExactETHForTokens(uint256,address[],address,uint256)",0,path,_to,deadline));
            (uint256[] memory amountOut) = abi.decode(result,(uint256[]));
            require( success , "swap ETH->TOKEN fail" );
            return amountOut[1];
        // } else {
        //     ( bool success1,) = address( _fromToken ).call( abi.encodeWithSignature( "approve(address,uint256)", routerAddr, amountIn ) );
        //     require( success1 , "tokenApprove Fail" );
        //     address[] memory path = new address[](3);
        //     (, bytes memory resultWETH) = address(iAddresses).staticcall(abi.encodeWithSignature("viewAddress(uint16)",uint16(103)));
        //     path[0] = _fromToken;
        //     path[1] = abi.decode(resultWETH,(address));
        //     path[2] = _toToken;
        //     (bool successSwap, bytes memory resultSwap) = address( routerAddr ).call(abi.encodeWithSignature("swapExactTokensForTokens(uint256,uint256,address[],address,uint256)",amountIn,0,path,_to,block.timestamp+1000));
        //     require( successSwap , "swap TOKEN->TOKEN Fail" );
        //     (uint256[] memory amountOut) = abi.decode(resultSwap,(uint256[]));
        //     return amountOut[1];
        // }
    }

    
    function checkFee(uint count) internal {
        uint8 n = 0;
        while (count >= 10) {
            count = count/10;
            n++;
        }
        require( msg.value > getPrice() * (n) , "C01");
    }

    function getPrice() internal view returns (uint256)
    {
        (,bytes memory resultRouter ) = address(iAddresses).staticcall(abi.encodeWithSignature("viewAddress(uint16)",1200));
        (address uniswapRouter) = abi.decode(resultRouter,(address));
        address[] memory path = new address[](2);
        (,bytes memory wBnbResult) = address(iAddresses).staticcall(abi.encodeWithSignature("viewAddress(uint16)",103));
        (,bytes memory usdtResult) = address(iAddresses).staticcall(abi.encodeWithSignature("viewAddress(uint16)",506)); // BUSD
        path[0] = abi.decode(usdtResult,(address));
        path[1] = abi.decode(wBnbResult,(address));
        (bool success, bytes memory result ) = address(uniswapRouter).staticcall(abi.encodeWithSignature("getAmountsOut(uint256,address[])",1000000000000000000,path));
        require(success,"callAmounts fail");
        uint[] memory a = abi.decode(result,(uint[]));
        return a[1];
    }
    
    function getCountFee(uint count) external view returns (uint256) {
        uint8 n = 0;
        if(count > 10) {
            while( count >= 10 ) {
                count = count/10;
                n++;
            }
            return getPrice() * n ;
        } else {
            return getPrice();
        }
    }
}
// File: UsePay/UsePAY/Pack/Pack.sol


pragma solidity >= 0.7.0;


contract Ticket is WrapAddresses {

    uint8 ver = 1;

    struct pack {
        uint32 hasCount;
        uint32 useCount;
    }
    
    address internal owner;
    uint256 internal quantity;
    uint256 internal refundCount = 0;
    
    struct PackInfo {
        uint32 total;
        uint32 times0;
        uint32 times1;
        uint32 times2;
        uint32 times3;
        uint256 price;
        uint8 tokenType;
        uint8 noshowValue;
        uint8 maxCount;
    }
    
    mapping(address=>pack) internal buyList;
    
    PackInfo internal packInfo;
    uint8 internal isCalculated = 0;
    uint32 internal totalUsedCount = 0;
}

contract Coupon is WrapAddresses {
    
    uint8 ver = 1;

    struct pack {
        uint32 hasCount;
        uint32 useCount;
    }
    
    uint256 internal quantity;
    
    mapping(address=>pack) internal buyList;
    
    struct PackInfo {
        uint32 total;
        uint32 maxCount;
        uint32 times0;
        uint32 times1;
        uint32 times2;
        uint32 times3;
    }
    address internal owner;
    PackInfo internal packInfo;
}

contract Subscription is WrapAddresses {

    uint8 ver = 1;

    struct pack {
        uint32 hasCount;
    }
    
    uint256 internal refundCount = 0;
    uint256 internal noshowCount = 0;
    uint256 internal noshowLimit = 0;
    uint256 internal quantity;
    uint256 internal isLive = 0;
    uint256 internal noShowTime = 0;
    address internal owner;
    
    struct PackInfo {
        uint32 total;
        uint32 times0;
        uint32 times1;
        uint32 times2;
        uint32 times3;
        uint256 price;
        uint8 tokenType;
    }
    
    mapping(address=>pack) internal buyList;
    
    PackInfo packInfo;
}
// File: UsePay/UsePAY/Commander/BSC/BSC_TicketCommander.sol


pragma solidity >= 0.7.0;



contract BSC_TicketCommander is Ticket,Commander {
  
    //-----------------------------------------
    //  events
    //-----------------------------------------
    event buyEvent(address indexed pack, uint256 buyNum, address buyer,uint256 count); // 0: pack indexed, 1: buyer, 2: count 
    event useEvent(address indexed pack, address user,uint256 count); // 0: pack indexed, 1: buyer, 2: count 
    event requestRefundEvent(address indexed pack, address buyer ,uint256 count, uint256 money, uint256 swap); // 0: pack indexed, 1: buyer, 2: count
    event calculateEvent(address indexed, address owner, uint256 value); 
    event changeTotalEvent(address indexed,uint256 _before,uint256 _after);

    //-----------------------------------------
    //  modifiers
    //-----------------------------------------
    
    
    modifier onlyOwner() { require ( msg.sender == owner, "O01" ); _; }
    modifier onCaculateTime() { require ( block.timestamp > packInfo.times3 , "CT01" );  _; }
    modifier canUse(uint256 count) { 
        require ( buyList[msg.sender].hasCount - buyList[msg.sender].useCount >= count, "U02" );
        _; 
    }
    modifier canBuy(uint256 count) { 

        require ( block.timestamp >= packInfo.times0 && block.timestamp <= packInfo.times1, "B01" ); 
        require ( quantity - count >= 0 , "B04"); 
        if ( packInfo.tokenType ==  100 ) {
            require ( msg.value == packInfo.price*( count ) , "B03" );
        } else {
            (,bytes memory tokenResult) = address(iAddresses).staticcall(abi.encodeWithSignature("viewAddress(uint16)",uint16(packInfo.tokenType)));
            (bool success,) = address(abi.decode(tokenResult,(address))).call(abi.encodeWithSignature("transferFrom(address,address,uint256)",msg.sender, address( this ), packInfo.price*( count )));
            require ( success , "T01");
        }
        _; 
        
    }

    function _percentValue(uint value, uint8 percent) private view returns (uint) {
        (,bytes memory resultPercent) = address(iAddresses).staticcall(abi.encodeWithSignature("viewAddress(uint16)",1300));
        address percentAddr = abi.decode(resultPercent,(address));
        (,bytes memory resultPercentValue) = address(percentAddr).staticcall(abi.encodeWithSignature("getValue(uint256,uint256)",value,percent));
        return abi.decode(resultPercentValue,(uint));
    }

    function _buy(uint32 count, address buyer) private {
        buyList[buyer].hasCount = buyList[buyer].hasCount+( count );
        quantity = quantity - count ;
    }
    
    function _refund( address _to,uint value, uint8 percent  ) private returns (uint256,uint256) {
        uint refundValue = 0;
        uint refundPercentValue = 0;
        uint swapValue = 0;
        uint feeValue = 0;
        if(packInfo.tokenType == 100 ) { // TOKEN == BSC
            refundValue = _percentValue(value,(100-percent));
            refundPercentValue = value - refundValue;
        }else {
            if(block.timestamp>packInfo.times3) {
                refundValue = _percentValue(value,98);
                feeValue = value - refundValue;
            } else {
                refundValue = value;
            }
        }
        if (refundValue != 0 ) {
            _transfer(packInfo.tokenType,_to,refundValue);
        }
        if (refundPercentValue != 0 ) {
            swapValue = _swap(_to,refundPercentValue);
        }
        if (feeValue != 0 ) {
            ( ,bytes memory result0 ) = address(iAddresses).staticcall(abi.encodeWithSignature("viewAddress(uint16)",0));
             _transfer(packInfo.tokenType,abi.decode(result0,(address)),feeValue);
        }
        return (refundValue,swapValue);
    }
    

    
    //-----------------------------------------
    //  payableFunctions
    //-----------------------------------------

    

    
    function buy( uint32 count , uint256 buyNum ) external payable canBuy(count) {
        require (count<=packInfo.maxCount,"B05");
        _buy(count, msg.sender);
        emit buyEvent(  address( this ), buyNum, msg.sender, count );
    }
    
    function give(address[] memory toAddr) external payable canUse( toAddr.length ) {
        buyList[msg.sender].hasCount = buyList[msg.sender].hasCount- uint32(toAddr.length);
        for(uint i=0; i<toAddr.length; i++) {
            buyList[toAddr[i]].hasCount++;
        }
        emit giveEvent( address(this), msg.sender, toAddr );
    }
    
    // function gift( address[] memory toAddr ) external payable canBuy(toAddr.length){
    //     for ( uint i =0; i<toAddr.length; i++) {
    //         buyList[toAddr[i]].hasCount++;
    //     }
    //     quantity = quantity - toAddr.length ;
    //     emit giftEvent( address(this), msg.sender, toAddr);
    // }
    
    function use( uint32 _count ) external payable canUse( _count ) {
        require ( block.timestamp > packInfo.times2, "U01" );
        totalUsedCount = totalUsedCount + _count;
        buyList[msg.sender].useCount = buyList[msg.sender].useCount+(_count);
        _transfer( packInfo.tokenType, owner, packInfo.price*( _count ) );
        emit useEvent( address( this ), msg.sender, _count );
    }
    
    function requestRefund( uint32 _count ) external payable canUse(_count) {
        uint256 refundValue = 0;
        uint256 swapValue = 0;
        if ( block.timestamp < packInfo.times3 ) { // in useTime
            ( refundValue,swapValue ) = _refund(msg.sender,packInfo.price * _count,0);
            totalUsedCount = totalUsedCount + _count;
        } else if (block.timestamp > packInfo.times3) { // out useTime
            uint totalValue = packInfo.price * _count;
            uint value = _percentValue(totalValue,100-packInfo.noshowValue);
            ( refundValue, swapValue ) = _refund(msg.sender,value,5);
        }
        buyList[msg.sender].hasCount = buyList[msg.sender].hasCount - _count;
        if (block.timestamp < packInfo.times1) {
            quantity = quantity + _count;
        }
        emit requestRefundEvent(address(this),msg.sender,_count,refundValue,swapValue);
    }
    
    function calculate() external payable onlyOwner onCaculateTime {
        require(isCalculated == 0,"CT03");
        uint quantityCount = packInfo.total - quantity - totalUsedCount;
        uint qunaityValue = _percentValue(packInfo.price,packInfo.noshowValue) * quantityCount;
        _transfer(packInfo.tokenType,owner,qunaityValue);
        isCalculated = 1;
        emit calculateEvent(address(this),owner,qunaityValue);
    }
    
    function changeTotal(uint32 _count) external payable onlyOwner {
        require(packInfo.total - quantity <= _count,"count too high");
        if ( _count > packInfo.total ) {
            checkFee(_count-packInfo.total);    
            _swap(msg.sender,msg.value);
            quantity = quantity + ( _count - packInfo.total );
        } else {
            quantity = quantity - ( packInfo.total - _count );
        }
        emit changeTotalEvent(address(this),packInfo.total,_count);
        packInfo.total = _count;
    }
    
    
    //-----------------------------------------
    //  viewFunctions
    //-----------------------------------------
    function viewInfo() external view returns (PackInfo memory) { return packInfo; }
    
    function viewUser(address _addr) external view returns (pack memory) { return buyList[_addr]; }
    
    function viewQuantity() external view returns (uint256) { return quantity; }
    
    function viewOwner() external view returns (address) { return owner; }

    function viewVersion() external view returns (uint8) { return ver; }
    function viewTotalUsedCount() external view returns (uint32) { return totalUsedCount; }
}