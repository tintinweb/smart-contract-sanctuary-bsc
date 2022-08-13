/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: BSL 1.1
// Coin Ranro Lottery v 0.1

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

contract lotteryCoinRango {

    address owner;
    uint numberLottery = 0;
    uint price_ticket = 5000000000000000;

    uint[] private numberWin = [22,33,13,43,1,3];

    uint[] private listNumber_Lottery = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90]; 

    struct lotteryDetails{
        uint num_1;
        uint num_2;
        uint num_3;
        uint num_4;
        uint num_5;
        uint num_6;
        uint prizes_six;
        uint prizes_five;
        uint prizes_four;
        uint prizes_three;
        uint prizes_two;
        uint ascertained_six;
        uint ascertained_five;
        uint ascertained_four;
        uint ascertained_three;
        uint ascertained_two;
        uint ascertained_one;
        uint mount_prize_six;
        uint mount_prize_five;
        uint mount_prize_four;
        uint mount_prize_three;
        uint mount_prize_two;
        uint mount_prize_total;
        uint mount_next_draw;
        bool draw;
    }

    struct Player{
        uint ticket;
        uint[][] numbers;
        bool awarded;
    }

    struct Ticket{
        address Address;
        //numero di ticket 
        uint numberTicket;
        //numeri che il user a messo nel ticket
        uint[][] numbers;
        //numeri che sono accertati
        uint[][] numbersWin;
        //Fila da pagare
        uint[][] rowToPay;
        //divanta true se è stato controllato i numeri
        bool ctr_number;
        //diventa true se hai vinto
        bool awarded;
        //totale a pagare
        uint totalToPay;
    }

    Ticket[][] listTickets;

    struct ticketResult{
        string str_numberWin;
        uint[] numberWin;
        uint qyt_number_win;
    }

    lotteryDetails[] listLotteryHistory;

    mapping( string => uint ) private code_bonus;

    mapping( address => mapping( string => uint ) ) private player_bonus;

    mapping( string => uint ) private code_bonus_one_use_only;

    constructor(){
        
        owner = msg.sender;
        
        create_new_lottery( 0 );

    }

    function create_new_lottery( uint mount ) internal{
        //aggiungiamo un nuovo numero di lotteria in quessto caso il 0
        listTickets.push();
        //aggiungiamo un nuovo detagli di lotteria in questo caso seria il 0
        listLotteryHistory.push( lotteryDetails( 0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0, mount, 0, false ) );
    }

    modifier onlyOwner{
        require( msg.sender == owner, "Only the owner can on view list" );
        _;
    }

    //registrare un nuovo prezzo di ogni giocata, solo lo pu
    function set_price( uint price ) public onlyOwner{
        price_ticket = price;
    }

    //per vederre il prezzo di ogni giocada
    function get_price() public view returns( uint ){
        return price_ticket;
    }

    //per registrare un nuovo codice bonus con la quantita di giocate
    function set_code_bonus( string memory code_player, uint _bonus ) public onlyOwner returns( uint ){
        
        code_bonus[code_player] = _bonus + 1;

        return code_bonus[code_player];
    }

    //per registrare un nuovo codice bonus un solo uso con la quantita di giocate
    function set_code_bonus_one_use_only( string memory code_player, uint _bonus ) public onlyOwner returns( uint ){
        
        code_bonus_one_use_only[code_player] = _bonus + 1;

        return code_bonus_one_use_only[code_player];
    }

    function st2num(string memory numString) internal pure returns(uint) {
        uint  val = 0;
        bytes   memory stringBytes = bytes(numString);
        for (uint  i =  0; i<stringBytes.length; i++) {
            uint exp = stringBytes.length - i;
            bytes1 ival = stringBytes[i];
            uint8 uval = uint8(ival);
           uint jval = uval - uint(0x30);
   
           val +=  (uint(jval) * (10**(exp-1))); 
        }
      return val;
    }

    //controllo per vedere se un codice bonus e valito
    function checkCodeBonus(string memory _code_bonus) public onlyOwner view returns (bool) {
        return code_bonus[_code_bonus] > 0 ? true : false;
    }

    //controllo per vedere se un codice bonus e valito
    function checkCodeBonusOneUseOnly(string memory _code_bonus) public onlyOwner view returns (bool) {
        return code_bonus_one_use_only[_code_bonus] > 0 ? true : false;
    }

    //per controllare se un player a usato su codice o per registrare
    function checkPlayerBonus( address _player, string memory _code_bonus, uint qty_bonus ) private returns (bool) {

        if( code_bonus[_code_bonus] > qty_bonus ){

            bool state =  player_bonus[_player][_code_bonus] == 0 ? false : true;
            
            if( !state ){
                player_bonus[msg.sender][_code_bonus] = code_bonus[_code_bonus] - 1;
                return true;
            }else if( player_bonus[_player][_code_bonus] > 1 && qty_bonus < player_bonus[_player][_code_bonus] ){
                player_bonus[_player][_code_bonus] = player_bonus[_player][_code_bonus] - qty_bonus;
                return true;
            }else{
                return false;
            }

        }else{
            
            return false;

        }
    }

    //per controllare se un player a usato il codice bonus di un solo uso
    function checkPlayerBonusOneUseOnly( string memory _code_bonus, uint qty_bonus ) private returns (bool) {

        if( code_bonus_one_use_only[_code_bonus] > qty_bonus ){

             code_bonus_one_use_only[_code_bonus] =  ( code_bonus_one_use_only[_code_bonus] - qty_bonus );

             return true;

        }else{
            
            return false;

        }
    }

    function get_my_bonus( string memory _code_bonus ) public view returns( uint ){

        return player_bonus[msg.sender][_code_bonus] - 1;

    }
    
    //contract.addTicketPlayerLottery()
    function addTicketPlayerLottery( uint[][] memory numbers ) private  returns( string memory, uint, string[] memory ){
        
        uint numberTicket = listTickets[numberLottery].length;

        //Creamo un array vuoto per nel futturo riempire con i numeri vincitori
        uint[][] memory numbersWin;
        uint[][] memory rowTo_pay;
        Ticket memory myTicket = Ticket( msg.sender, numberTicket, numbers, numbersWin, rowTo_pay, false, false, 0 );
        
        //insertiamo il ticket nel array principale del tickes
        listTickets[numberLottery].push( myTicket );

        string memory t_r = string( abi.encodePacked( 
            " Your ticket number is: ",
            Strings.toString( numberTicket ),
            " Number Lottery: ", Strings.toString(numberLottery) ) );
        
        
        string[] memory details_number = new string[](numbers.length);

        for( uint r = 0; r < numbers.length; r++ ){
            uint[] memory row = numbers[r];
            string memory nums = "";
            for( uint n = 0; n < row.length; n++ ){
                if( n == 0 ){
                    nums = string( abi.encodePacked( nums, Strings.toString( row[n] ) ) );
                }else{
                    nums = string( abi.encodePacked( nums, ",", Strings.toString( row[n] ) ) );
                }
            }
            details_number[r] = string( abi.encodePacked( " Row#:", Strings.toString(r + 1), " Numbers: ", nums ) );
        }

        
        return ( t_r, numberTicket, details_number );

    }

    // acquistare un ticket
    function addTicketPayable_PlayerLottery( uint[][] memory numbers ) public payable returns( string memory, uint, string[] memory){
        //TEST [[22,33,54,6,7,88],[7,16,24,39,44,89]]

        uint i_mount_to_pay = numbers.length * price_ticket;

        //Aggiungiamo il pagamento fatto del ticket
        listLotteryHistory[numberLottery].mount_prize_total += i_mount_to_pay;
        
        require( msg.value == i_mount_to_pay, "Il tuo pagameto non va bene controlla il prezzo da pagare" );

        return addTicketPlayerLottery( numbers );

    }

    // acquistare un ticket col bonus
    function addTicketBonus_PlayerLottery( uint[][] memory numbers, string memory _code_bonus ) public returns( string memory, uint, string[] memory){

        require( checkCodeBonus( _code_bonus ), "Il codice del bonus no e registrato" );

        require( checkPlayerBonus( msg.sender,  _code_bonus, numbers.length ), "Il tuo codice hai gia usato" );

        return addTicketPlayerLottery( numbers );

    }

    // acquistare un ticket col bonus
    function addTicketBonusOneUseOnly_PlayerLottery( uint[][] memory numbers, string memory _code_bonus ) public returns( string memory, uint, string[] memory){

        require( checkCodeBonusOneUseOnly( _code_bonus ), "Il codice del bonus no e registrato" );

        require( checkPlayerBonusOneUseOnly( _code_bonus, numbers.length ), "Il tuo codice hai gia usato" );

        return addTicketPlayerLottery( numbers );

    }

    //Solo per vedere i numeri del Ticket
    function viewTicketPlayerLottery(uint _numberLottery, uint _numberTicket ) public view returns(string[] memory){

        Ticket memory viewTicket = listTickets[_numberLottery][_numberTicket];

        string[] memory str_result = new string[](viewTicket.numbers.length);

        for( uint r = 0; r < viewTicket.numbers.length; r++ ){
            string memory nums = "";
            uint[] memory row = viewTicket.numbers[r];

            for( uint n = 0; n < row.length; n++ ){

                if( n == 0 ){
                    nums = string( abi.encodePacked( nums, Strings.toString( row[n] ) ) );
                }else{
                    nums = string( abi.encodePacked( nums, ",", Strings.toString( row[n] ) ) );
                }
            }

            str_result[r] = string( abi.encodePacked( 
                " row#: ",
                Strings.toString( r ),
                " Numbers: ", nums  ) );
        }

        return str_result;
    }

    //cercare i numeri che hanno combaciato
    function searchNumbreWin( uint[]  memory numbers) public view returns(ticketResult memory){
        
        require( numbers.length == 6, "You quantity not is six group" );
        
        uint correct = 0;
        
        string memory listYouWinPlayer = "";

        for( uint n = 0; n < numbers.length; n++ ){
            for( uint w = 0; w < numberWin.length; w++ ){
                if( numbers[n] == numberWin[w] ){
                    if( correct == 0 ){
                        listYouWinPlayer = string( abi.encodePacked( listYouWinPlayer, Strings.toString( numberWin[w] ) ) );
                    }else{
                        listYouWinPlayer = string( abi.encodePacked( listYouWinPlayer, ",", Strings.toString( numberWin[w] ) ) );
                    }
                    correct++;
                }
            }
        }
        
        uint[] memory numbers_win = new uint[](correct);

        uint num_temp = 0;
        
        for( uint n = 0; n < numbers.length; n++ ){
            for( uint w = 0; w < numberWin.length; w++ ){
                if( numbers[n] == numberWin[w] ){
                    numbers_win[num_temp] = numberWin[w];
                    num_temp++;
                }
            }
        }

        return ticketResult({
            str_numberWin : listYouWinPlayer,
            numberWin : numbers_win,
            qyt_number_win : correct
        });
    }

    //cerca se un ticket a vinto
    function searchTikectWin( uint _numberLottery, uint _numberTicket ) public view returns(string[] memory, string[] memory) {

        Ticket memory viewTicket = listTickets[_numberLottery][_numberTicket];

        string[] memory str_result = new string[](viewTicket.numbers.length);

        string[] memory str_result_win = new string[](viewTicket.numbers.length);

        uint[] memory prize_pay;
        
        ticketResult[] memory listResult = new ticketResult[](viewTicket.numbers.length);

        for( uint r = 0; r < viewTicket.numbers.length; r++ ){
            
            string memory nums = "";
            
            uint[] memory row = viewTicket.numbers[r];

            for( uint n = 0; n < row.length; n++ ){

                if( n == 0 ){
                    nums = string( abi.encodePacked( nums, Strings.toString( row[n] ) ) );
                }else{
                    nums = string( abi.encodePacked( nums, ",", Strings.toString( row[n] ) ) );
                }
            }

            str_result[r] = string( abi.encodePacked( 
                " row#: ",
                Strings.toString( r ),
                " Numbers: ", nums  ) );

            listResult[r] = searchNumbreWin( viewTicket.numbers[r] );

            str_result_win[r] = string( abi.encodePacked( "Row #",
                            Strings.toString(r), ": you matched ",
                            Strings.toString(listResult[r].qyt_number_win),
                            " numbers, the numbers are ",
                            listResult[r].str_numberWin ) );
            
           if( listResult[r].qyt_number_win == 6 ){
                prize_pay[r] = listLotteryHistory[numberLottery].prizes_six;
            }else if( listResult[r].qyt_number_win == 5 ){
                prize_pay[r] = listLotteryHistory[numberLottery].prizes_five;
            }else if( listResult[r].qyt_number_win == 4 ){
                prize_pay[r] = listLotteryHistory[numberLottery].prizes_four;
            }else if( listResult[r].qyt_number_win == 3 ){
                prize_pay[r] = listLotteryHistory[numberLottery].prizes_three;
            }else if( listResult[r].qyt_number_win == 2 ){
                prize_pay[r] = listLotteryHistory[numberLottery].prizes_two;
            }
            

        }

        return ( str_result, str_result_win );
        
    }
    
    //Mescolare i numeri dentro del Array
    function mixTheNumbers( uint spin ) public returns( uint[] memory ){

        for( uint i = 0; i < spin; i++ ){
            uint num_ran = random(0, listNumber_Lottery.length - 1, i );
            uint mem = listNumber_Lottery[i];
            listNumber_Lottery[i] = listNumber_Lottery[num_ran];
            listNumber_Lottery[num_ran] = mem;
        }

        return listNumber_Lottery;
    }

    //controllare ogni ticket per vedere se hanno vinto e aggiornare il resultato della lottery
    function updateLotteryHistory() private {

        listLotteryHistory[numberLottery].num_1 = numberWin[0];
        listLotteryHistory[numberLottery].num_2 = numberWin[1];
        listLotteryHistory[numberLottery].num_3 = numberWin[2];
        listLotteryHistory[numberLottery].num_4 = numberWin[3];
        listLotteryHistory[numberLottery].num_5 = numberWin[4];
        listLotteryHistory[numberLottery].num_6 = numberWin[5];

        listLotteryHistory[numberLottery].mount_prize_six = listLotteryHistory[numberLottery].mount_prize_total * 40 / 100;
        listLotteryHistory[numberLottery].mount_prize_five = listLotteryHistory[numberLottery].mount_prize_total * 10 / 100;
        listLotteryHistory[numberLottery].mount_prize_four = listLotteryHistory[numberLottery].mount_prize_total * 9 / 100;
        listLotteryHistory[numberLottery].mount_prize_three = listLotteryHistory[numberLottery].mount_prize_total * 9 / 100;
        listLotteryHistory[numberLottery].mount_prize_two = listLotteryHistory[numberLottery].mount_prize_total * 9 / 100;

        listLotteryHistory[numberLottery].mount_next_draw = listLotteryHistory[numberLottery].mount_prize_total * 23 / 100;

        for( uint i = 0; i < listTickets[numberLottery].length; i++){
             
             Ticket memory viewTicket = listTickets[numberLottery][i];

             for( uint r = 0; r < viewTicket.numbers.length; r++ ){

                ticketResult memory result_row = searchNumbreWin( viewTicket.numbers[r] );

                if( result_row.qyt_number_win == 6 ){
                    listLotteryHistory[numberLottery].ascertained_six++;
                }else if( result_row.qyt_number_win == 5 ){
                    listLotteryHistory[numberLottery].ascertained_five++;
                }else if( result_row.qyt_number_win == 4 ){
                    listLotteryHistory[numberLottery].ascertained_four++;
                }else if( result_row.qyt_number_win == 3 ){
                    listLotteryHistory[numberLottery].ascertained_three++;
                }else if( result_row.qyt_number_win == 2 ){
                    listLotteryHistory[numberLottery].ascertained_two++;
                }else if( result_row.qyt_number_win == 1 ){
                    listLotteryHistory[numberLottery].ascertained_one++;
                }
            
            }

        }

        if( listLotteryHistory[numberLottery].ascertained_six > 0 ){
            listLotteryHistory[numberLottery].prizes_six =  listLotteryHistory[numberLottery].mount_prize_six / listLotteryHistory[numberLottery].ascertained_six;
        }else{
            listLotteryHistory[numberLottery].mount_next_draw += listLotteryHistory[numberLottery].mount_prize_six;
        }

        if( listLotteryHistory[numberLottery].ascertained_five > 0 ){
            listLotteryHistory[numberLottery].prizes_five =  listLotteryHistory[numberLottery].mount_prize_five / listLotteryHistory[numberLottery].ascertained_five;
        }else{
            listLotteryHistory[numberLottery].mount_next_draw += listLotteryHistory[numberLottery].mount_prize_five;
        }

        if( listLotteryHistory[numberLottery].ascertained_four > 0 ){
            listLotteryHistory[numberLottery].prizes_four =  listLotteryHistory[numberLottery].mount_prize_four / listLotteryHistory[numberLottery].ascertained_four;
        }else{
            listLotteryHistory[numberLottery].mount_next_draw += listLotteryHistory[numberLottery].mount_prize_four;
        }

        if( listLotteryHistory[numberLottery].ascertained_three > 0 ){
            listLotteryHistory[numberLottery].prizes_three =  listLotteryHistory[numberLottery].mount_prize_three / listLotteryHistory[numberLottery].ascertained_three;
        }else{
            listLotteryHistory[numberLottery].mount_next_draw += listLotteryHistory[numberLottery].mount_prize_three;
        }

        if( listLotteryHistory[numberLottery].ascertained_two > 0 ){
            listLotteryHistory[numberLottery].prizes_two =  listLotteryHistory[numberLottery].mount_prize_two / listLotteryHistory[numberLottery].ascertained_two;
        }else{
            listLotteryHistory[numberLottery].mount_next_draw += listLotteryHistory[numberLottery].mount_prize_two;
        }
        
    }

    //lista di numeri che hanno accertato
    function ascertained( uint _numberLottery ) external view returns( uint[] memory ){
        
        require( listLotteryHistory[_numberLottery].draw, "La strazzione della lotteria ancora non e fatta" );
        
        uint[] memory r = new uint[](6);
        
        r[0] = listLotteryHistory[_numberLottery].ascertained_six;
        r[1] = listLotteryHistory[_numberLottery].ascertained_five;
        r[2] = listLotteryHistory[_numberLottery].ascertained_four;
        r[3] = listLotteryHistory[_numberLottery].ascertained_three;
        r[4] = listLotteryHistory[_numberLottery].ascertained_two;
        r[5] = listLotteryHistory[_numberLottery].ascertained_one;

        return r;

    }

    //lista di premi che sono per ognuno
    function amounts( uint _numberLottery ) public view returns( uint[] memory ){

        uint[] memory result = new uint[](6);

        // il premio totale chi sara diviso fra i vincitori che hanno fatto 6
        result[0] = listLotteryHistory[_numberLottery].mount_prize_total * 40 / 100;
        // il premio totale chi sara diviso fra i vincitori che hanno fatto 5
        result[1] = listLotteryHistory[_numberLottery].mount_prize_total * 10 / 100;
        // il premio totale chi sara diviso fra i vincitori che hanno fatto 4
        result[2] = listLotteryHistory[_numberLottery].mount_prize_total * 9 / 100;
        // il premio totale chi sara diviso fra i vincitori che hanno fatto 3
        result[3] = listLotteryHistory[_numberLottery].mount_prize_total * 9 / 100;
        // il premio totale chi sara diviso fra i vincitori che hanno fatto 2
        result[4] = listLotteryHistory[_numberLottery].mount_prize_total * 9 / 100;
        // il total acomulato per la prossima estrazzione
        result[5] = listLotteryHistory[_numberLottery].mount_prize_total * 23 / 100;

        return result;

    }

    //quantita di BNB che passano per la prossima estrazzione
    function mount_next_draw() public view returns( uint ){
        return listLotteryHistory[numberLottery].mount_prize_total * 23 / 100;
    }

    // numeri della strazzione della lotteria n
    function lottery_mount_prize_total( uint number_lottery ) public view returns( uint ) {
        return listLotteryHistory[number_lottery].mount_prize_total;
    }

    //premio che corrisponde a ogni acerti
    function player_prizes( uint _numberLottery) public view returns( uint[] memory ) {

        require( listLotteryHistory[_numberLottery].draw, "La strazzione della lotteria ancora non e fatta" );
        
        uint[] memory result = new uint[](5);

        // il che va datto a ogni player che hanno fatto 6
        result[0] = listLotteryHistory[_numberLottery].prizes_six;
        // il che va datto a ogni player che hanno fatto 5
        result[1] = listLotteryHistory[_numberLottery].prizes_five;
        // il che va datto a ogni player che hanno fatto 4
        result[2] = listLotteryHistory[_numberLottery].prizes_four;
        // il che va datto a ogni player che hanno fatto 3
        result[3] = listLotteryHistory[_numberLottery].prizes_three;
        // il che va datto a ogni player che hanno fatto 2
        result[4] = listLotteryHistory[_numberLottery].prizes_two;

        return result;

    }

    //Estrazzioni dei numeri
    function extractSixNumberRandom() public onlyOwner returns( uint[] memory ){

        uint256[] memory result_number = new uint256[](6);
        
        for( uint i = 0; i < 6; i++ ){
            
            uint num_ran1 = random( 0, ( listNumber_Lottery.length - i ) - 1, 1 );
            
            uint men_num1 = listNumber_Lottery[ ( listNumber_Lottery.length - i ) - 1 ];

            result_number[i] = listNumber_Lottery[num_ran1];

            numberWin[i] = result_number[i];
            
            listNumber_Lottery[  ( listNumber_Lottery.length - i ) - 1 ] = result_number[i];
            
            listNumber_Lottery[num_ran1] = men_num1;

        }

        updateLotteryHistory();

        listLotteryHistory[numberLottery].draw = true;

        return numberWin;
    }

    //quantida di tickes aquistati
    function qtyTickets_currentLottery( uint _numberLottery ) public view returns( uint ){
        return listTickets[_numberLottery].length;
    }

    //formazione del Array di ogni numero
    function viewNumberOnBall() external view returns( uint[] memory ) {
        return listNumber_Lottery;
    }

    //mumeri vincitore della lotteria numero
    function numbersDrawnLottery( uint _numberLottery ) external view returns( uint[] memory ){
        
        require( listLotteryHistory[_numberLottery].draw, "La strazzione della lotteria ancora non e fatta" );

        uint[] memory r = new uint[](6);

        r[0] = listLotteryHistory[_numberLottery].num_1;
        r[1] = listLotteryHistory[_numberLottery].num_2;
        r[2] = listLotteryHistory[_numberLottery].num_3;
        r[3] = listLotteryHistory[_numberLottery].num_4;
        r[4] = listLotteryHistory[_numberLottery].num_5;
        r[5] = listLotteryHistory[_numberLottery].num_6;

        return r;
    }

    //funzione per il random dei numerri
    function random( uint start, uint end, uint code ) private view returns(uint){
        return uint( keccak256( 
            abi.encodePacked(
                block.timestamp,
                code,
                start ) ) ) % end + 1;
    }
}