pragma solidity ^0.7.6;

import "hardhat/console.sol";
import "../ILocalToken.sol";

// taken from : https://etherscan.io/address/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2#code
contract TestWrappedNative is ILocalToken {
    string constant public localTokenType = "TestWrappedNative";

    function getLocalTokenType() external view override returns (string memory) {
        return localTokenType;
    }

    string public name     = "Wrapped Ether";
    string public symbol   = "WETH";
    uint8  public decimals = 18;

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    function deposit() external payable {
        console.log("TestWrappedNative::deposit:: Sender %s deposits %d to TestWrappedNative", msg.sender, msg.value);
        depositInternal(msg.sender, msg.value);
    }
    function withdraw(uint wad) public {
        console.log("TestWrappedNative::withdraw:: Sender %s with balance %d withdraws %d from TestWrappedNative", msg.sender, balanceOf[msg.sender], wad);
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        msg.sender.transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }

    // DEV_NOTE : This function is here to match the 'TestErc20' format
    function mint(address account, uint256 amount) external {
        balanceOf[account] += amount;
        console.log("TestWrappedNative::mint:: Minted %d for %s", amount, account);
        console.log("TestWrappedNative::mint:: Balance: ", balanceOf[account], "At", address(this));
        console.log("TestWrappedNative::mint:: SHOULD AVOID USING 'mint' on WETH !!!");
    }

//    function receive() external payable {
//        console.log("TestWrappedNative::receive:: %d from %s", msg.value, msg.sender);
//        depositInternal(msg.sender, msg.value);
//    }

//    fallback() external payable {
//        console.log("TestWrappedNative::fallback:: %d from %s", msg.value, msg.sender);
//        depositInternal(msg.sender, msg.value);
//    }

    function totalSupply() public view returns (uint) {
        return (address(this)).balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
    public
    returns (bool)
    {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }

    function depositInternal(address account, uint amount) internal {
        balanceOf[account] += amount;
        emit Deposit(account, amount);
    }
}


/*
                    GNU GENERAL PUBLIC LICENSE
                       Version 3, 29 June 2007

 Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

                            Preamble

  The GNU General Public License is a free, copyleft license for
software and other kinds of works.

  The licenses for most software and other practical works are designed
to take away your freedom to share and change the works.  By contrast,
the GNU General Public License is intended to guarantee your freedom to
share and change all versions of a program--to make sure it remains free
software for all its users.  We, the Free Software Foundation, use the
GNU General Public License for most of our software; it applies also to
any other work released this way by its authors.  You can apply it to
your programs, too.

  When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
them if you wish), that you receive source code or can get it if you
want it, that you can change the software or use pieces of it in new
free programs, and that you know you can do these things.

  To protect your rights, we need to prevent others from denying you
these rights or asking you to surrender the rights.  Therefore, you have
certain responsibilities if you distribute copies of the software, or if
you modify it: responsibilities to respect the freedom of others.

  For example, if you distribute copies of such a program, whether
gratis or for a fee, you must pass on to the recipients the same
freedoms that you received.  You must make sure that they, too, receive
or can get the source code.  And you must show them these terms so they
know their rights.

  Developers that use the GNU GPL protect your rights with two steps:
(1) assert copyright on the software, and (2) offer you this License
giving you legal permission to copy, distribute and/or modify it.

  For the developers' and authors' protection, the GPL clearly explains
that there is no warranty for this free software.  For both users' and
authors' sake, the GPL requires that modified versions be marked as
changed, so that their problems will not be attributed erroneously to
authors of previous versions.

  Some devices are designed to deny users access to install or run
modified versions of the software inside them, although the manufacturer
can do so.  This is fundamentally incompatible with the aim of
protecting users' freedom to change the software.  The systematic
pattern of such abuse occurs in the area of products for individuals to
use, which is precisely where it is most unacceptable.  Therefore, we
have designed this version of the GPL to prohibit the practice for those
products.  If such problems arise substantially in other domains, we
stand ready to extend this provision to those domains in future versions
of the GPL, as needed to protect the freedom of users.

  Finally, every program is threatened constantly by software patents.
States should not allow patents to restrict development and use of
software on general-purpose computers, but in those that do, we wish to
avoid the special danger that patents applied to a free program could
make it effectively proprietary.  To prevent this, the GPL assures that
patents cannot be used to render the program non-free.

  The precise terms and conditions for copying, distribution and
modification follow.

                       TERMS AND CONDITIONS

  0. Definitions.

  "This License" refers to version 3 of the GNU General Public License.

  "Copyright" also means copyright-like laws that apply to other kinds of
works, such as semiconductor masks.

  "The Program" refers to any copyrightable work licensed under this
License.  Each licensee is addressed as "you".  "Licensees" and
"recipients" may be individuals or organizations.

  To "modify" a work means to copy from or adapt all or part of the work
in a fashion requiring copyright permission, other than the making of an
exact copy.  The resulting work is called a "modified version" of the
earlier work or a work "based on" the earlier work.

  A "covered work" means either the unmodified Program or a work based
on the Program.

  To "propagate" a work means to do anything with it that, without
permission, would make you directly or secondarily liable for
infringement under applicable copyright law, except executing it on a
computer or modifying a private copy.  Propagation includes copying,
distribution (with or without modification), making available to the
public, and in some countries other activities as well.

  To "convey" a work means any kind of propagation that enables other
parties to make or receive copies.  Mere interaction with a user through
a computer network, with no transfer of a copy, is not conveying.

  An interactive user interface displays "Appropriate Legal Notices"
to the extent that it includes a convenient and prominently visible
feature that (1) displays an appropriate copyright notice, and (2)
tells the user that there is no warranty for the work (except to the
extent that warranties are provided), that licensees may convey the
work under this License, and how to view a copy of this License.  If
the interface presents a list of user commands or options, such as a
menu, a prominent item in the list meets this criterion.

  1. Source Code.

  The "source code" for a work means the preferred form of the work
for making modifications to it.  "Object code" means any non-source
form of a work.

  A "Standard Interface" means an interface that either is an official
standard defined by a recognized standards body, or, in the case of
interfaces specified for a particular programming language, one that
is widely used among developers working in that language.

  The "System Libraries" of an executable work include anything, other
than the work as a whole, that (a) is included in the normal form of
packaging a Major Component, but which is not part of that Major
Component, and (b) serves only to enable use of the work with that
Major Component, or to implement a Standard Interface for which an
implementation is available to the public in source code form.  A
"Major Component", in this context, means a major essential component
(kernel, window system, and so on) of the specific operating system
(if any) on which the executable work runs, or a compiler used to
produce the work, or an object code interpreter used to run it.

  The "Corresponding Source" for a work in object code form means all
the source code needed to generate, install, and (for an executable
work) run the object code and to modify the work, including scripts to
control those activities.  However, it does not include the work's
System Libraries, or general-purpose tools or generally available free
programs which are used unmodified in performing those activities but
which are not part of the work.  For example, Corresponding Source
includes interface definition files associated with source files for
the work, and the source code for shared libraries and dynamically
linked subprograms that the work is specifically designed to require,
such as by intimate data communication or control flow between those
subprograms and other parts of the work.

  The Corresponding Source need not include anything that users
can regenerate automatically from other parts of the Corresponding
Source.

  The Corresponding Source for a work in source code form is that
same work.

  2. Basic Permissions.

  All rights granted under this License are granted for the term of
copyright on the Program, and are irrevocable provided the stated
conditions are met.  This License explicitly affirms your unlimited
permission to run the unmodified Program.  The output from running a
covered work is covered by this License only if the output, given its
content, constitutes a covered work.  This License acknowledges your
rights of fair use or other equivalent, as provided by copyright law.

  You may make, run and propagate covered works that you do not
convey, without conditions so long as your license otherwise remains
in force.  You may convey covered works to others for the sole purpose
of having them make modifications exclusively for you, or provide you
with facilities for running those works, provided that you comply with
the terms of this License in conveying all material for which you do
not control copyright.  Those thus making or running the covered works
for you must do so exclusively on your behalf, under your direction
and control, on terms that prohibit them from making any copies of
your copyrighted material outside their relationship with you.

  Conveying under any other circumstances is permitted solely under
the conditions stated below.  Sublicensing is not allowed; section 10
makes it unnecessary.

  3. Protecting Users' Legal Rights From Anti-Circumvention Law.

  No covered work shall be deemed part of an effective technological
measure under any applicable law fulfilling obligations under article
11 of the WIPO copyright treaty adopted on 20 December 1996, or
similar laws prohibiting or restricting circumvention of such
measures.

  When you convey a covered work, you waive any legal power to forbid
circumvention of technological measures to the extent such circumvention
is effected by exercising rights under this License with respect to
the covered work, and you disclaim any intention to limit operation or
modification of the work as a means of enforcing, against the work's
users, your or third parties' legal rights to forbid circumvention of
technological measures.

  4. Conveying Verbatim Copies.

  You may convey verbatim copies of the Program's source code as you
receive it, in any medium, provided that you conspicuously and
appropriately publish on each copy an appropriate copyright notice;
keep intact all notices stating that this License and any
non-permissive terms added in accord with section 7 apply to the code;
keep intact all notices of the absence of any warranty; and give all
recipients a copy of this License along with the Program.

  You may charge any price or no price for each copy that you convey,
and you may offer support or warranty protection for a fee.

  5. Conveying Modified Source Versions.

  You may convey a work based on the Program, or the modifications to
produce it from the Program, in the form of source code under the
terms of section 4, provided that you also meet all of these conditions:

    a) The work must carry prominent notices stating that you modified
    it, and giving a relevant date.

    b) The work must carry prominent notices stating that it is
    released under this License and any conditions added under section
    7.  This requirement modifies the requirement in section 4 to
    "keep intact all notices".

    c) You must license the entire work, as a whole, under this
    License to anyone who comes into possession of a copy.  This
    License will therefore apply, along with any applicable section 7
    additional terms, to the whole of the work, and all its parts,
    regardless of how they are packaged.  This License gives no
    permission to license the work in any other way, but it does not
    invalidate such permission if you have separately received it.

    d) If the work has interactive user interfaces, each must display
    Appropriate Legal Notices; however, if the Program has interactive
    interfaces that do not display Appropriate Legal Notices, your
    work need not make them do so.

  A compilation of a covered work with other separate and independent
works, which are not by their nature extensions of the covered work,
and which are not combined with it such as to form a larger program,
in or on a volume of a storage or distribution medium, is called an
"aggregate" if the compilation and its resulting copyright are not
used to limit the access or legal rights of the compilation's users
beyond what the individual works permit.  Inclusion of a covered work
in an aggregate does not cause this License to apply to the other
parts of the aggregate.

  6. Conveying Non-Source Forms.

  You may convey a covered work in object code form under the terms
of sections 4 and 5, provided that you also convey the
machine-readable Corresponding Source under the terms of this License,
in one of these ways:

    a) Convey the object code in, or embodied in, a physical product
    (including a physical distribution medium), accompanied by the
    Corresponding Source fixed on a durable physical medium
    customarily used for software interchange.

    b) Convey the object code in, or embodied in, a physical product
    (including a physical distribution medium), accompanied by a
    written offer, valid for at least three years and valid for as
    long as you offer spare parts or customer support for that product
    model, to give anyone who possesses the object code either (1) a
    copy of the Corresponding Source for all the software in the
    product that is covered by this License, on a durable physical
    medium customarily used for software interchange, for a price no
    more than your reasonable cost of physically performing this
    conveying of source, or (2) access to copy the
    Corresponding Source from a network server at no charge.

    c) Convey individual copies of the object code with a copy of the
    written offer to provide the Corresponding Source.  This
    alternative is allowed only occasionally and noncommercially, and
    only if you received the object code with such an offer, in accord
    with subsection 6b.

    d) Convey the object code by offering access from a designated
    place (gratis or for a charge), and offer equivalent access to the
    Corresponding Source in the same way through the same place at no
    further charge.  You need not require recipients to copy the
    Corresponding Source along with the object code.  If the place to
    copy the object code is a network server, the Corresponding Source
    may be on a different server (operated by you or a third party)
    that supports equivalent copying facilities, provided you maintain
    clear directions next to the object code saying where to find the
    Corresponding Source.  Regardless of what server hosts the
    Corresponding Source, you remain obligated to ensure that it is
    available for as long as needed to satisfy these requirements.

    e) Convey the object code using peer-to-peer transmission, provided
    you inform other peers where the object code and Corresponding
    Source of the work are being offered to the general public at no
    charge under subsection 6d.

  A separable portion of the object code, whose source code is excluded
from the Corresponding Source as a System Library, need not be
included in conveying the object code work.

  A "User Product" is either (1) a "consumer product", which means any
tangible personal property which is normally used for personal, family,
or household purposes, or (2) anything designed or sold for incorporation
into a dwelling.  In determining whether a product is a consumer product,
doubtful cases shall be resolved in favor of coverage.  For a particular
product received by a particular user, "normally used" refers to a
typical or common use of that class of product, regardless of the status
of the particular user or of the way in which the particular user
actually uses, or expects or is expected to use, the product.  A product
is a consumer product regardless of whether the product has substantial
commercial, industrial or non-consumer uses, unless such uses represent
the only significant mode of use of the product.

  "Installation Information" for a User Product means any methods,
procedures, authorization keys, or other information required to install
and execute modified versions of a covered work in that User Product from
a modified version of its Corresponding Source.  The information must
suffice to ensure that the continued functioning of the modified object
code is in no case prevented or interfered with solely because
modification has been made.

  If you convey an object code work under this section in, or with, or
specifically for use in, a User Product, and the conveying occurs as
part of a transaction in which the right of possession and use of the
User Product is transferred to the recipient in perpetuity or for a
fixed term (regardless of how the transaction is characterized), the
Corresponding Source conveyed under this section must be accompanied
by the Installation Information.  But this requirement does not apply
if neither you nor any third party retains the ability to install
modified object code on the User Product (for example, the work has
been installed in ROM).

  The requirement to provide Installation Information does not include a
requirement to continue to provide support service, warranty, or updates
for a work that has been modified or installed by the recipient, or for
the User Product in which it has been modified or installed.  Access to a
network may be denied when the modification itself materially and
adversely affects the operation of the network or violates the rules and
protocols for communication across the network.

  Corresponding Source conveyed, and Installation Information provided,
in accord with this section must be in a format that is publicly
documented (and with an implementation available to the public in
source code form), and must require no special password or key for
unpacking, reading or copying.

  7. Additional Terms.

  "Additional permissions" are terms that supplement the terms of this
License by making exceptions from one or more of its conditions.
Additional permissions that are applicable to the entire Program shall
be treated as though they were included in this License, to the extent
that they are valid under applicable law.  If additional permissions
apply only to part of the Program, that part may be used separately
under those permissions, but the entire Program remains governed by
this License without regard to the additional permissions.

  When you convey a copy of a covered work, you may at your option
remove any additional permissions from that copy, or from any part of
it.  (Additional permissions may be written to require their own
removal in certain cases when you modify the work.)  You may place
additional permissions on material, added by you to a covered work,
for which you have or can give appropriate copyright permission.

  Notwithstanding any other provision of this License, for material you
add to a covered work, you may (if authorized by the copyright holders of
that material) supplement the terms of this License with terms:

    a) Disclaiming warranty or limiting liability differently from the
    terms of sections 15 and 16 of this License; or

    b) Requiring preservation of specified reasonable legal notices or
    author attributions in that material or in the Appropriate Legal
    Notices displayed by works containing it; or

    c) Prohibiting misrepresentation of the origin of that material, or
    requiring that modified versions of such material be marked in
    reasonable ways as different from the original version; or

    d) Limiting the use for publicity purposes of names of licensors or
    authors of the material; or

    e) Declining to grant rights under trademark law for use of some
    trade names, trademarks, or service marks; or

    f) Requiring indemnification of licensors and authors of that
    material by anyone who conveys the material (or modified versions of
    it) with contractual assumptions of liability to the recipient, for
    any liability that these contractual assumptions directly impose on
    those licensors and authors.

  All other non-permissive additional terms are considered "further
restrictions" within the meaning of section 10.  If the Program as you
received it, or any part of it, contains a notice stating that it is
governed by this License along with a term that is a further
restriction, you may remove that term.  If a license document contains
a further restriction but permits relicensing or conveying under this
License, you may add to a covered work material governed by the terms
of that license document, provided that the further restriction does
not survive such relicensing or conveying.

  If you add terms to a covered work in accord with this section, you
must place, in the relevant source files, a statement of the
additional terms that apply to those files, or a notice indicating
where to find the applicable terms.

  Additional terms, permissive or non-permissive, may be stated in the
form of a separately written license, or stated as exceptions;
the above requirements apply either way.

  8. Termination.

  You may not propagate or modify a covered work except as expressly
provided under this License.  Any attempt otherwise to propagate or
modify it is void, and will automatically terminate your rights under
this License (including any patent licenses granted under the third
paragraph of section 11).

  However, if you cease all violation of this License, then your
license from a particular copyright holder is reinstated (a)
provisionally, unless and until the copyright holder explicitly and
finally terminates your license, and (b) permanently, if the copyright
holder fails to notify you of the violation by some reasonable means
prior to 60 days after the cessation.

  Moreover, your license from a particular copyright holder is
reinstated permanently if the copyright holder notifies you of the
violation by some reasonable means, this is the first time you have
received notice of violation of this License (for any work) from that
copyright holder, and you cure the violation prior to 30 days after
your receipt of the notice.

  Termination of your rights under this section does not terminate the
licenses of parties who have received copies or rights from you under
this License.  If your rights have been terminated and not permanently
reinstated, you do not qualify to receive new licenses for the same
material under section 10.

  9. Acceptance Not Required for Having Copies.

  You are not required to accept this License in order to receive or
run a copy of the Program.  Ancillary propagation of a covered work
occurring solely as a consequence of using peer-to-peer transmission
to receive a copy likewise does not require acceptance.  However,
nothing other than this License grants you permission to propagate or
modify any covered work.  These actions infringe copyright if you do
not accept this License.  Therefore, by modifying or propagating a
covered work, you indicate your acceptance of this License to do so.

  10. Automatic Licensing of Downstream Recipients.

  Each time you convey a covered work, the recipient automatically
receives a license from the original licensors, to run, modify and
propagate that work, subject to this License.  You are not responsible
for enforcing compliance by third parties with this License.

  An "entity transaction" is a transaction transferring control of an
organization, or substantially all assets of one, or subdividing an
organization, or merging organizations.  If propagation of a covered
work results from an entity transaction, each party to that
transaction who receives a copy of the work also receives whatever
licenses to the work the party's predecessor in interest had or could
give under the previous paragraph, plus a right to possession of the
Corresponding Source of the work from the predecessor in interest, if
the predecessor has it or can get it with reasonable efforts.

  You may not impose any further restrictions on the exercise of the
rights granted or affirmed under this License.  For example, you may
not impose a license fee, royalty, or other charge for exercise of
rights granted under this License, and you may not initiate litigation
(including a cross-claim or counterclaim in a lawsuit) alleging that
any patent claim is infringed by making, using, selling, offering for
sale, or importing the Program or any portion of it.

  11. Patents.

  A "contributor" is a copyright holder who authorizes use under this
License of the Program or a work on which the Program is based.  The
work thus licensed is called the contributor's "contributor version".

  A contributor's "essential patent claims" are all patent claims
owned or controlled by the contributor, whether already acquired or
hereafter acquired, that would be infringed by some manner, permitted
by this License, of making, using, or selling its contributor version,
but do not include claims that would be infringed only as a
consequence of further modification of the contributor version.  For
purposes of this definition, "control" includes the right to grant
patent sublicenses in a manner consistent with the requirements of
this License.

  Each contributor grants you a non-exclusive, worldwide, royalty-free
patent license under the contributor's essential patent claims, to
make, use, sell, offer for sale, import and otherwise run, modify and
propagate the contents of its contributor version.

  In the following three paragraphs, a "patent license" is any express
agreement or commitment, however denominated, not to enforce a patent
(such as an express permission to practice a patent or covenant not to
sue for patent infringement).  To "grant" such a patent license to a
party means to make such an agreement or commitment not to enforce a
patent against the party.

  If you convey a covered work, knowingly relying on a patent license,
and the Corresponding Source of the work is not available for anyone
to copy, free of charge and under the terms of this License, through a
publicly available network server or other readily accessible means,
then you must either (1) cause the Corresponding Source to be so
available, or (2) arrange to deprive yourself of the benefit of the
patent license for this particular work, or (3) arrange, in a manner
consistent with the requirements of this License, to extend the patent
license to downstream recipients.  "Knowingly relying" means you have
actual knowledge that, but for the patent license, your conveying the
covered work in a country, or your recipient's use of the covered work
in a country, would infringe one or more identifiable patents in that
country that you have reason to believe are valid.

  If, pursuant to or in connection with a single transaction or
arrangement, you convey, or propagate by procuring conveyance of, a
covered work, and grant a patent license to some of the parties
receiving the covered work authorizing them to use, propagate, modify
or convey a specific copy of the covered work, then the patent license
you grant is automatically extended to all recipients of the covered
work and works based on it.

  A patent license is "discriminatory" if it does not include within
the scope of its coverage, prohibits the exercise of, or is
conditioned on the non-exercise of one or more of the rights that are
specifically granted under this License.  You may not convey a covered
work if you are a party to an arrangement with a third party that is
in the business of distributing software, under which you make payment
to the third party based on the extent of your activity of conveying
the work, and under which the third party grants, to any of the
parties who would receive the covered work from you, a discriminatory
patent license (a) in connection with copies of the covered work
conveyed by you (or copies made from those copies), or (b) primarily
for and in connection with specific products or compilations that
contain the covered work, unless you entered into that arrangement,
or that patent license was granted, prior to 28 March 2007.

  Nothing in this License shall be construed as excluding or limiting
any implied license or other defenses to infringement that may
otherwise be available to you under applicable patent law.

  12. No Surrender of Others' Freedom.

  If conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License.  If you cannot convey a
covered work so as to satisfy simultaneously your obligations under this
License and any other pertinent obligations, then as a consequence you may
not convey it at all.  For example, if you agree to terms that obligate you
to collect a royalty for further conveying from those to whom you convey
the Program, the only way you could satisfy both those terms and this
License would be to refrain entirely from conveying the Program.

  13. Use with the GNU Affero General Public License.

  Notwithstanding any other provision of this License, you have
permission to link or combine any covered work with a work licensed
under version 3 of the GNU Affero General Public License into a single
combined work, and to convey the resulting work.  The terms of this
License will continue to apply to the part which is the covered work,
but the special requirements of the GNU Affero General Public License,
section 13, concerning interaction through a network will apply to the
combination as such.

  14. Revised Versions of this License.

  The Free Software Foundation may publish revised and/or new versions of
the GNU General Public License from time to time.  Such new versions will
be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

  Each version is given a distinguishing version number.  If the
Program specifies that a certain numbered version of the GNU General
Public License "or any later version" applies to it, you have the
option of following the terms and conditions either of that numbered
version or of any later version published by the Free Software
Foundation.  If the Program does not specify a version number of the
GNU General Public License, you may choose any version ever published
by the Free Software Foundation.

  If the Program specifies that a proxy can decide which future
versions of the GNU General Public License can be used, that proxy's
public statement of acceptance of a version permanently authorizes you
to choose that version for the Program.

  Later license versions may give you additional or different
permissions.  However, no additional obligations are imposed on any
author or copyright holder as a result of your choosing to follow a
later version.

  15. Disclaimer of Warranty.

  THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY
APPLICABLE LAW.  EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT
HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY
OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM
IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF
ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

  16. Limitation of Liability.

  IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS
THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY
GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE
USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF
DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD
PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS),
EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

  17. Interpretation of Sections 15 and 16.

  If the disclaimer of warranty and limitation of liability provided
above cannot be given local legal effect according to their terms,
reviewing courts shall apply local law that most closely approximates
an absolute waiver of all civil liability in connection with the
Program, unless a warranty or assumption of liability accompanies a
copy of the Program in return for a fee.

                     END OF TERMS AND CONDITIONS

            How to Apply These Terms to Your New Programs

  If you develop a new program, and you want it to be of the greatest
possible use to the public, the best way to achieve this is to make it
free software which everyone can redistribute and change under these terms.

  To do so, attach the following notices to the program.  It is safest
to attach them to the start of each source file to most effectively
state the exclusion of warranty; and each file should have at least
the "copyright" line and a pointer to where the full notice is found.

    <one line to give the program's name and a brief idea of what it does.>
    Copyright (C) <year>  <name of author>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

Also add information on how to contact you by electronic and paper mail.

  If the program does terminal interaction, make it output a short
notice like this when it starts in an interactive mode:

    <program>  Copyright (C) <year>  <name of author>
    This program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type `show c' for details.

The hypothetical commands `show w' and `show c' should show the appropriate
parts of the General Public License.  Of course, your program's commands
might be different; for a GUI interface, you would use an "about box".

  You should also get your employer (if you work as a programmer) or school,
if any, to sign a "copyright disclaimer" for the program, if necessary.
For more information on this, and how to apply and follow the GNU GPL, see
<http://www.gnu.org/licenses/>.

  The GNU General Public License does not permit incorporating your program
into proprietary programs.  If your program is a subroutine library, you
may consider it more useful to permit linking proprietary applications with
the library.  If this is what you want to do, use the GNU Lesser General
Public License instead of this License.  But first, please read
<http://www.gnu.org/philosophy/why-not-lgpl.html>.

*/

// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}

pragma solidity ^0.7.6;

interface ILocalToken {
    function getLocalTokenType() external view returns (string calldata );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";
import "./ILocalToken.sol";

contract TestErc20 is ERC20, ILocalToken {
    string constant  public localTokenType = "TestErc20";

    function getLocalTokenType() external view override returns (string memory) {
        return localTokenType;
    }

    constructor (string memory name_, string memory symbol_, uint8 decimals_) ERC20(name_, symbol_) {
        _setupDecimals(decimals_);
    }

    function mint(address account, uint256 amount) external virtual {
        _mint(account, amount);
        console.log("TestErc20::Minted %d for %s", amount, account);
        console.log("TestErc20::Balance: ", ERC20(this).balanceOf(account), "At", address(this));
    }

    function burn(address account, uint256 amount) external virtual {
        _burn(account, amount);
    }


    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        console.log("TestErc20::ERC20 Approval %s", name());
        console.log("TestErc20::ERC20 : Owner %s is approving to %s : %d", _msgSender(), spender, amount);
        _approve(_msgSender(), spender, amount);
        return true;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./IERC20.sol";
import "../../math/SafeMath.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./TestErc20.sol";

contract OwnableTestErc20 is TestErc20, Ownable {

    constructor (string memory name_, string memory symbol_, uint8 decimals_) TestErc20(name_, symbol_, decimals_) {
        
    }
    function mint(address account, uint256 amount) external virtual override onlyOwner {
        _mint(account, amount);
        console.log("TestErc20::Minted %d for %s", amount, account);
        console.log("TestErc20::Balance: ", ERC20(this).balanceOf(account), "At", address(this));
    }
     function burn(address account, uint256 amount) external virtual override onlyOwner{
        _burn(account, amount);
        console.log("TestErc20::Burned %d for %s", amount, account);
        console.log("TestErc20::Balance: ", ERC20(this).balanceOf(account), "At", address(this));
    }


}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IUniMirrorMaster.sol";
import "./IUniPairMirror.sol";

/// @dev : A simple contract that will be manually fed the mirrored pair state.
contract UniPairMirror is IUniPairMirror, Ownable {

    address public sot;

    // DEV_NOTE : Taken from https://github.com/Uniswap/uniswap-v2-core/blob/4dd59067c76dea4a0e8e4bfdda41877a6b16dedc/contracts/UniswapV2Pair.sol#L18-L27
    address public factory;
    address public token0;
    address public token1;

    uint112 private reserve0;           // uses single storage slot, accessible via getReserves
    uint112 private reserve1;           // uses single storage slot, accessible via getReserves
    // TODO : DEV_NOTE : beware of 2038 bug
    uint32  private blockTimestampLast; // uses single storage slot, accessible via getReserves

    // DEV_NOTE : Changed to private because of '"override" in state variable' compiling problem
    uint private price0CumulativeLastPrivate;
    uint private price1CumulativeLastPrivate;
    // DEV_NOTE : UP_UNTIL_HERE

    constructor(address _sot, address _token0, address _token1) {
        require(_token0 != _token1, "Identity pair");
        require(_token0 < _token1, "Wrong order of tokens");

        sot = _sot;

        factory = msg.sender;
        token0 = _token0;
        token1 = _token1;

        emit SotUpdated(address(0), sot, block.timestamp);
    }

    function getReserves() external override view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast)
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function price0CumulativeLast() external override view returns (uint) {
        return price0CumulativeLastPrivate;
    }

    function price1CumulativeLast() external override view returns (uint) {
        return price1CumulativeLastPrivate;
    }

    function getPairGist() external view override returns (
        address _sot,
        address _token0,
        address _token1,
        uint112 _reserve0,
        uint112 _reserve1,
        uint256 _price0CumulativeLast,
        uint256 _price1CumulativeLast,
        uint32 _blockTimestampLast) {
        _sot = sot;
        _token0 = token0;
        _token1 = token1;
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _price0CumulativeLast = price0CumulativeLastPrivate;
        _price1CumulativeLast = price1CumulativeLastPrivate;
        _blockTimestampLast = blockTimestampLast;
    }

    function getAddresses() external override view returns (
        address _sot,
        address _token0,
        address _token1
    ) {
        _sot = sot;
        _token0 = token0;
        _token1 = token1;
    }

    function getMirrorState() external override view returns (
        uint112 _reserve0,
        uint112 _reserve1,
        uint256 _price0CumulativeLast,
        uint256 _price1CumulativeLast,
        uint32 _blockTimestampLast
    ) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _price0CumulativeLast = price0CumulativeLastPrivate;
        _price1CumulativeLast = price1CumulativeLastPrivate;
        _blockTimestampLast = blockTimestampLast;
    }

    function getSot() external override view returns (address) {
        return sot;
    }

    function updateSot(address newSot) external override onlyOwner() {
        address oldSot = sot;
        sot = newSot;
        emit SotUpdated(oldSot, sot, block.timestamp);
    }

    function updateMirroredState(
        uint112 _reserve0,
        uint112 _reserve1,
        uint256 _price0Cumulative,
        uint256 _price1Cumulative,
        uint32 _timestamp) external override onlyOwner() {
        _updateMirroredStateInternal(_reserve0, _reserve1, _price0Cumulative, _price1Cumulative, _timestamp);
    }

    function _updateMirroredStateInternal(
        uint112 _reserve0,
        uint112 _reserve1,
        uint256 _price0Cumulative,
        uint256 _price1Cumulative,
        uint32 _timestamp) internal returns (bool) {

        reserve0 = _reserve0;
        reserve1 = _reserve1;
        price0CumulativeLastPrivate = _price0Cumulative;
        price1CumulativeLastPrivate = _price1Cumulative;
        blockTimestampLast = _timestamp;

        emit MirroredStateUpdated(blockTimestampLast, price0CumulativeLastPrivate, price1CumulativeLastPrivate);

        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

// TODO : Consider changing boolean to error codes
interface IUniMirrorMaster {

    /// Indicates registration of a new pair mirror
    event PairMirrorDeployed(address indexed token0, address indexed token1, address pair);

    /// Indicates an address is now allowed to update the pair mirror
    event UpdaterRegistered(address indexed pair, address indexed permissionGiver, address indexed permissionReceiver);

    /// Indicates an new address is now NOT allowed to update the pair mirror
    event UpdaterUnregistered(address indexed pair, address indexed permissionGiver, address indexed permissionReceiver);

    /// Returns the gist for the given pair
    function getPairGist(address pair) external view returns (
        address _sot,
        address _token0,
        address _token1,
        uint112 _reserve0,
        uint112 _reserve1,
        uint256 _price0CumulativeLast,
        uint256 _price1CumulativeLast,
        uint32 _blockTimestampLast
    );

    /// Did this contract create the given pair ?
    function isPairMirrorKnown(address pair) external view returns (bool);

    /// Is an updater for the given pair ?
    function isPairUpdater(address pair, address updater) external view returns (bool);

    /// Do the given tokens have a mirror pair (regardless of the order) ?
    function hasMirrorForTokens(address tokenA, address tokenB) external view returns (bool);

    // Returns the mirror-pair address for the given tokens (regardless of order)
    // TODO : C.F.H : Add all of the 'order not matter'
    function getMirrorAddressForTokens(address tokenA, address tokenB) external view returns (address);

    /// Deploys an instance of 'IUniPairMirror' for the given addresses.
    /// Address0-Address1 must be ordered ascending.
    function createPair(address sot, address address0, address address1) external returns (address);

    /// Deploys an instance of 'IUniPairMirror' for the given addresses.
    /// Address0-Address1 must be ordered ascending. (for each tuple)
    function createPairs(
        address[] calldata sots,
        address[] calldata addresses0,
        address[] calldata addresses1
    ) external returns (address[] memory);

    /// Adds the given address as a valid updater for the pair
    /// The pair must be a known pair.
    function addUpdater(address pair, address updater) external;

    /// Removes the given address as a valid updater for the pair
    /// The pair must be a known pair.
    function removeUpdater(address pair, address updater) external;

    /// Updates the mirror state for the given pair.
    /// Caller must be a valid updater for the given pair.
    function updateMirroredState(address pair,
        uint112 reserve0,
        uint112 reserve1,
        uint256 price0Cumulative,
        uint256 price1Cumulative,
        uint32 timestamp) external returns (bool);

    /// Updates the mirror state for the given pair.
    /// Caller must be a valid updater for the given pair.
    function updateMirroredStates(address[] calldata pairAddresses,
        uint112[] calldata reserves0,
        uint112[] calldata reserves1,
        uint256[] calldata prices0Cumulative,
        uint256[] calldata prices1Cumulative,
        uint32[] calldata timestamps) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "../../Ola/Peripheral/PriceOracle/open-oracle/Uniswap/UniswapLib.sol";

interface IUniPairMirror is IUniswapV2PairForStateReading {
    /// Indicates a change in the Sot
    event SotUpdated(address indexed oldSot, address indexed newSot, uint256 timestamp);

    /// Indicates the mirrored data about a pair was updates
    event MirroredStateUpdated(uint256 timestamp, uint256 price0Cumulative, uint256 price1Culumlative);

    /// Returns the addresses and the mirrored state
    function getPairGist() external view returns (
        address _sot,
        address _token0,
        address _token1,
        uint112 _reserve0,
        uint112 _reserve1,
        uint256 _price0CumulativeLast,
        uint256 _price1CumulativeLast,
        uint32 _blockTimestampLast);

    /// Returns the addresses
    function getAddresses() external view returns (
        address _sot,
        address _token0,
        address _token1
    );

    /// Returns the mirrored state
    function getMirrorState() external view returns (
        uint112 _reserve0,
        uint112 _reserve1,
        uint256 _price0CumulativeLast,
        uint256 _price1CumulativeLast,
        uint32 _blockTimestampLast
    );

    /// Returns the source of truth for this pair.
    function getSot() external view returns (address);

    // Updates the Sot for this pair mirror.
    function updateSot(address newSot) external;

    /// Updates the mirrored state
    function updateMirroredState(
        uint112 reserve0,
        uint112 reserve1,
        uint256 price0Cumulative,
        uint256 price1Cumulative,
        uint32 timestamp) external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.6;

// Based on code from https://github.com/Uniswap/uniswap-v2-periphery

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))
library FixedPoint {
    // range: [0, 2**112 - 1]
    // resolution: 1 / 2**112
    struct uq112x112 {
        uint224 _x;
    }

    // returns a uq112x112 which represents the ratio of the numerator to the denominator
    // equivalent to encode(numerator).div(denominator)
    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << 112) / denominator);
    }

    // decode a uq112x112 into a uint with 18 decimals of precision
    function decode112with18(uq112x112 memory self) internal pure returns (uint) {
        // we only have 256 - 224 = 32 bits to spare, so scaling up by ~60 bits is dangerous
        // instead, get close to:
        //  (x * 1e18) >> 112
        // without risk of overflowing, e.g.:
        //  (x) / 2 ** (112 - lg(1e18))
        return uint(self._x) / 5192296858534827;
    }
}

// library with helper methods for oracles that are concerned with computing average prices
library UniswapV2OracleLibrary {
    using FixedPoint for *;

    // helper function that returns the current block timestamp within the range of uint32, i.e. [0, 2**32 - 1]
    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2 ** 32);
    }

    // produces the cumulative price using counterfactuals to save gas and avoid a call to sync.
    function currentCumulativePrices(
        address pair
    ) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {
        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2PairForStateReading(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2PairForStateReading(pair).price1CumulativeLast();

        // if time has elapsed since the last update on the pair, mock the accumulated price values
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2PairForStateReading(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            // subtraction overflow is desired
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            // addition overflow is desired
            // counterfactual
            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            // counterfactual
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}

interface IUniswapV2PairForStateReading {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IUniMirrorMaster.sol";
import "./IUniPairMirror.sol";
import "./UniPairMirror.sol";

contract UniMirrorMaster is IUniMirrorMaster, Ownable {

    // DEV_NOTE : We will have a reasonably limited amount of pairs.
    address[] public pairMirrors;

    // PairMirror => flag
    mapping(address => bool) private registeredPairMirrors;

    // PairMirror => Updater => flag
    mapping(address => mapping(address => bool)) mirrorUpdaters;

    // token0 => token1 => pair
    mapping(address => mapping(address => address)) private mirrorsForTokens;

    function getPairGist(address pair) external override view returns (
        address _sot,
        address _token0,
        address _token1,
        uint112 _reserve0,
        uint112 _reserve1,
        uint256 _price0CumulativeLast,
        uint256 _price1CumulativeLast,
        uint32 _blockTimestampLast
    ) {
        return IUniPairMirror(pair).getPairGist();
    }

    function getAllPairsAddresses() external view returns (
        address[] memory pairs,
        address[] memory sots,
        address[] memory tokens0,
        address[] memory tokens1
    ) {
        pairs = new address[](pairMirrors.length);
        sots = new address[](pairMirrors.length);
        tokens0 = new address[](pairMirrors.length);
        tokens1 = new address[](pairMirrors.length);

        for (uint i = 0; i < pairMirrors.length; i++) {
            address pair = pairMirrors[i];
            address sot;
            address token0;
            address token1;
            (sot, token0, token1) = IUniPairMirror(pair).getAddresses();
            pairs[i] = pair;
            sots[i] = sot;
            tokens0[i] = token0;
            tokens1[i] = token1;
        }
    }

    /// Getter for the 'pairMirrors' array
    function getAllPairMirrors() external view returns (address[] memory) {
        return pairMirrors;
    }

    function isPairMirrorKnown(address pair) external override view returns (bool) {
        return _isPairMirrorKnown(pair);
    }

    function isPairUpdater(address pair, address updater) external override view returns (bool) {
        return _isPairUpdater(pair, updater);
    }

    function hasMirrorForTokens(address tokenA, address tokenB) external override view returns (bool) {
        return _hasMirrorForTokens(tokenA, tokenB);
    }

    function getMirrorAddressForTokens(address tokenA, address tokenB) external override view returns (address) {
        return _getMirrorAddressForTokens(tokenA, tokenB);
    }

    function createPair(
        address sot,
        address address0,
        address address1
    ) external override onlyOwner() returns (address) {
        address deployer = msg.sender;
        return _createPairInternal(deployer, sot, address0, address1);
    }

    function createPairs(
        address[] calldata sots,
        address[] calldata addresses0,
        address[] calldata addresses1) external override onlyOwner() returns (address[] memory) {
        // Validate inputs lengths
        require(addresses0.length == addresses1.length, "addresses0 must be same length as addresses1");
        require(addresses0.length == sots.length, "sots must match the length of the addressees");

        address deployer = msg.sender;
        address[] memory results = new address[](addresses0.length);

        for (uint i = 0; i < addresses0.length; i++) {
            results[i] = _createPairInternal(deployer, sots[i], addresses0[i], addresses1[i]);
        }

        return results;
    }

    function addUpdater(address pair, address updater) external override onlyOwner() {
        _addMirrorUpdater(pair, msg.sender, updater);
    }

    function removeUpdater(address pair, address updater) external override onlyOwner() {
        _removeMirrorUpdater(pair, msg.sender, updater);
    }

    function updateMirroredState(address pair,
        uint112 reserve0,
        uint112 reserve1,
        uint256 price0Cumulative,
        uint256 price1Cumulative,
        uint32 timestamp) external override returns (bool) {
        address updater = msg.sender;
        return _updateMirroredState(updater, pair, reserve0, reserve1, price0Cumulative, price1Cumulative, timestamp);
    }

    function updateMirroredStates(address[] calldata pairAddresses,
        uint112[] calldata reserves0,
        uint112[] calldata reserves1,
        uint256[] calldata prices0Cumulative,
        uint256[] calldata prices1Cumulative,
        uint32[] calldata timestamps) external override
    {
        // Validate inputs lengths
        require(pairAddresses.length == reserves0.length, "reserves0 must be same length of 'pair addresses'");
        require(pairAddresses.length == reserves1.length, "reserves1 must be same length of 'pair addresses'");
        require(pairAddresses.length == prices0Cumulative.length, "prices0Cumulative must be same length of 'pair addresses'");
        require(pairAddresses.length == prices1Cumulative.length, "prices1Cumulative must be same length of 'pair addresses'");
        require(pairAddresses.length == timestamps.length, "timestamps must be same length of 'pair addresses'");

        for (uint i = 0; i < pairAddresses.length; i++) {
            _updateMirroredState(msg.sender, pairAddresses[i], reserves0[i], reserves1[i], prices0Cumulative[i], prices1Cumulative[i], timestamps[i]);
        }
    }

    function _createPairInternal(address deployer,
        address sot,
        address token0,
        address token1) internal returns (address) {

        require(!_hasMirrorForTokens(token0, token1), "A mirror exists for this token combinations");

        // DEV_NOTE : The order of the tokens is enforced by the 'UniPairMirror'
        // Deploy the contract
        UniPairMirror uniPairMirror = new UniPairMirror(sot, token0, token1);
        address pair = address(uniPairMirror);
        pairMirrors.push(pair);

        // Update local state
        registeredPairMirrors[pair] = true;
        mirrorsForTokens[token0][token1] = pair;
        mirrorsForTokens[token1][token0] = pair;
        _addMirrorUpdater(pair, msg.sender, deployer);

        // Events
        emit PairMirrorDeployed(token0, token1,pair);

        return pair;
    }

    function _updateMirroredState(address updater, address pair,
        uint112 reserve0,
        uint112 reserve1,
        uint256 price0Cumulative,
        uint256 price1Cumulative,
        uint32 timestamp) internal returns (bool) {
        require(_isPairUpdater(pair, updater), "Not an updater for the pair");
        require(_isPairMirrorKnown(pair), "Must be a known pair mirror");

        // Update the pair mirror
        IUniPairMirror(pair).updateMirroredState(reserve0, reserve1, price0Cumulative, price1Cumulative, timestamp);

        return true;
    }

    function _addMirrorUpdater(address pairMirror, address approver, address updater) private {
        if (_isPairUpdater(pairMirror, updater)) {
            return;
        }

        mirrorUpdaters[pairMirror][updater] = true;
        emit UpdaterRegistered(pairMirror, approver, updater);
    }

    function _removeMirrorUpdater(address pairMirror, address approver, address updater) private {
        if (!_isPairUpdater(pairMirror, updater)) {
            return;
        }

        mirrorUpdaters[pairMirror][updater] = false;
        emit UpdaterUnregistered(pairMirror, approver, updater);
    }

    function _isPairMirrorKnown(address pair) internal view returns (bool) {
        return registeredPairMirrors[pair];
    }

    function _isPairUpdater(address pair, address updater) internal view returns (bool) {
        return mirrorUpdaters[pair][updater];
    }

    function _hasMirrorForTokens(address tokenA, address tokenB) internal view returns (bool) {
        return _getMirrorAddressForTokens(tokenA, tokenB) != address(0);
    }

    function _getMirrorAddressForTokens(address tokenA, address tokenB) internal view returns (address) {
        return mirrorsForTokens[tokenA][tokenB];
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "../OpenOraclePriceData.sol";
import "./UniswapConfig.sol";
import "./UniswapLib.sol";

interface RegistryForUAV {
    function getPriceForAsset(address cToken) external view returns (uint256);
}

struct Observation {
    uint timestamp;
    uint acc;
}

contract UniswapAnchoredView is UniswapConfig {
    using FixedPoint for *;

    string[] public autoPokingSymbols;

    /// @notice The Open Oracle Price Data contract
    OpenOraclePriceData public immutable priceData;

    /// @notice The number of wei in 1 ETH
    uint public constant ethBaseUnit = 1e18;

    /// @notice A common scaling factor to maintain precision
    uint public constant expScale = 1e18;

    /// @notice The Open Oracle Reporter
    address public immutable reporter;

    /// @notice The highest ratio of the new price to the anchor price that will still trigger the price to be updated
    uint public immutable upperBoundAnchorRatio;

    /// @notice The lowest ratio of the new price to the anchor price that will still trigger the price to be updated
    uint public immutable lowerBoundAnchorRatio;

    /// @notice The minimum amount of time in seconds required for the old uniswap price accumulator to be replaced
    uint public immutable anchorPeriod;

    /// @notice Official prices by symbol hash
    mapping(bytes32 => uint) public prices;

    /// @notice Last 'Official price' update timestamp
    /// OLA_ADDITIONS : This field
    mapping(bytes32 => uint) public pricesLastUpdate;

    /// @notice Circuit breaker for using anchor price oracle directly, ignoring reporter
    bool public reporterInvalidated;

    /// @notice The old observation for each symbolHash
    mapping(bytes32 => Observation) public oldObservations;

    /// @notice The new observation for each symbolHash
    mapping(bytes32 => Observation) public newObservations;

    /// @notice The event emitted when new prices are posted but the stored price is not updated due to the anchor
    event PriceGuarded(string symbol, uint reporter, uint anchor);

    /// @notice The event emitted when the stored price is updated
    event PriceUpdated(string symbol, uint price);

    /// @notice The event emitted when anchor price is updated
    event AnchorPriceUpdated(string symbol, uint anchorPrice, uint oldTimestamp, uint newTimestamp);

    /// @notice The event emitted when the uniswap window changes
    event UniswapWindowUpdated(bytes32 indexed symbolHash, uint oldTimestamp, uint newTimestamp, uint oldPrice, uint newPrice);

    /// @notice The event emitted when reporter invalidates itself
    event ReporterInvalidated(address reporter);

    bytes32 constant ethHash = keccak256(abi.encodePacked("ETH"));
    bytes32 constant rotateHash = keccak256(abi.encodePacked("rotate"));
    string public referenceAssetSymbol;
    bytes32 public referenceAssetHash;
    uint public usdBaseUnit;
    address public registry;

    /**
     * @notice Construct a uniswap anchored view for a set of token configurations
     * @dev Note that to avoid immature TWAPs, the system must run for at least a single anchorPeriod before using.
     * @param reporter_ The reporter whose prices are to be used
     * @param referenceAssetSymbol_ The asset('s symbol) to measure the prices of all other (non fixed) assets against.
     * @param usdBaseUnit_ Amount that equal to 1 scaled by the base USD token decimals.
     * @param anchorToleranceMantissa_ The percentage tolerance that the reporter may deviate from the uniswap anchor
     * @param anchorPeriod_ The minimum amount of time required for the old uniswap price accumulator to be replaced
     * @param configs The static token configurations which define what prices are supported and how
     */
    constructor(OpenOraclePriceData priceData_,
                address reporter_,
                string memory referenceAssetSymbol_,
                uint usdBaseUnit_,
                uint anchorToleranceMantissa_,
                uint anchorPeriod_,
                address registry_,
                TokenConfig[] memory configs,
                string[] memory _autoPokingSymbols) UniswapConfig(configs) public {
        priceData = priceData_;
        reporter = reporter_;
        anchorPeriod = anchorPeriod_;
        registry = registry_;
        autoPokingSymbols = _autoPokingSymbols;

        referenceAssetSymbol = referenceAssetSymbol_;
        referenceAssetHash = keccak256(abi.encodePacked(referenceAssetSymbol));
        usdBaseUnit = usdBaseUnit_;

        // Allow the tolerance to be whatever the deployer chooses, but prevent under/overflow (and prices from being 0)
        upperBoundAnchorRatio = anchorToleranceMantissa_ > uint(-1) - 100e16 ? uint(-1) : 100e16 + anchorToleranceMantissa_;
        lowerBoundAnchorRatio = anchorToleranceMantissa_ < 100e16 ? 100e16 - anchorToleranceMantissa_ : 1;

        for (uint i = 0; i < configs.length; i++) {
            TokenConfig memory config = configs[i];
            require(config.baseUnit > 0, "baseUnit must be greater than zero");
            address uniswapMarket = config.uniswapMarket;
            if (config.priceSource == PriceSource.REPORTER || config.priceSource == PriceSource.UNISWAP) {
                require(uniswapMarket != address(0), "reported prices must have an anchor");
                bytes32 symbolHash = config.symbolHash;
                uint cumulativePrice = currentCumulativePrice(config);
                oldObservations[symbolHash].timestamp = block.timestamp;
                newObservations[symbolHash].timestamp = block.timestamp;
                oldObservations[symbolHash].acc = cumulativePrice;
                newObservations[symbolHash].acc = cumulativePrice;
                emit UniswapWindowUpdated(symbolHash, block.timestamp, block.timestamp, cumulativePrice, cumulativePrice);
            } else {
                require(uniswapMarket == address(0), "only reported prices utilize an anchor");
            }

            require(PriceSource.ORACLE != config.priceSource || address(0) != registry_, "Registry address required for using oracle asset");
        }
    }

    /**
     * @notice Get the array of symbols that can be auto poked.
     */
    function getAllAutoPokingSymbols() external view returns (string[] memory) {
        return autoPokingSymbols;
    }

    /**
     * @notice Get the official price for a symbol
     * @param symbol The symbol to fetch the price of
     * @return Price denominated in USD, with 6 decimals
     */
    function price(string memory symbol) external view returns (uint) {
        TokenConfig memory config = getTokenConfigBySymbol(symbol);
        return priceInternal(config);
    }

    function priceInternal(TokenConfig memory config) internal view returns (uint) {
        if (config.priceSource == PriceSource.REPORTER || config.priceSource == PriceSource.UNISWAP || config.priceSource == PriceSource.SIGNED_ONLY || config.priceSource == PriceSource.ORACLE) return prices[config.symbolHash];
        if (config.priceSource == PriceSource.FIXED_USD) return config.fixedPrice;
        if (config.priceSource == PriceSource.FIXED_ETH) {
            uint usdPerEth = prices[ethHash];
            require(usdPerEth > 0, "ETH price not set, cannot convert to dollars");
            return mul(usdPerEth, config.fixedPrice) / ethBaseUnit;
        }
    }

    /**
     * @notice Get the price an asset
     * @param asset The asset to get the price of
     * @return The asset price mantissa (scaled by 1e18).
     *  Zero means the price is unavailable.
     */
    function getAssetPrice(address asset) external view returns (uint) {
        return getAssetPriceInternal(asset);
    }

    /**
     * @notice Get the price update timestamp for the asset
     * @param asset The asset address for price update timestamp retrieval.
     * @return Last price update timestamp for the asset
     */
    function getAssetPriceUpdateTimestamp(address asset) external view returns (uint) {
        return getAssetPriceUpdateTimestampInternal(asset);
    }

    /**
     * @notice Get the underlying price of a cToken
     * @dev Implements the PriceOracle interface for Compound v2.
     * @param cToken The cToken address for price retrieval
     * @return Price denominated in USD, with 18 decimals, for the given cToken address
     */
    function getUnderlyingPrice(address cToken) external view returns (uint) {
        return getAssetPriceInternal(CErc20ForUniswapConfig(cToken).underlying());
    }

    /**
     * OLA_ADDITIONS : This function
     * @notice Get the price update timestamp for the cToken underlying
     * @dev Implements the PriceOracle interface for Compound v2.
     * @param cToken The cToken address for price update timestamp retrieval.
     * @return Last price update timestamp for the cToken underlying asset
     */
    function getUnderlyingPriceUpdateTimestamp(address cToken) external view returns (uint) {
        return getAssetPriceUpdateTimestampInternal(CErc20ForUniswapConfig(cToken).underlying());
    }

    /**
     * @notice Post open oracle reporter prices, and recalculate stored price by comparing to anchor
     * @dev We let anyone pay to post anything, but only prices from configured reporter will be stored in the view.
     * @param messages The messages to post to the oracle
     * @param signatures The signatures for the corresponding messages
     * @param symbols The symbols to compare to anchor for authoritative reading
     */
    function postPrices(bytes[] calldata messages, bytes[] calldata signatures, string[] calldata symbols) external {
        require(messages.length == signatures.length, "messages and signatures must be 1:1");

        // Save the prices
        for (uint i = 0; i < messages.length; i++) {
            TokenConfig memory config = getTokenConfigBySymbol(symbols[i]);
            if (config.priceSource == PriceSource.REPORTER || config.priceSource == PriceSource.SIGNED_ONLY) {
                priceData.put(messages[i], signatures[i]);
            }
        }

        // OLA_ADDITIONS : Using 'core asset price' instead of 'ethPrice
        uint referenceAssetPrice = fetchReferenceAssetPrice();

        // Try to update the view storage
        for (uint i = 0; i < symbols.length; i++) {
            postPriceInternal(symbols[i], referenceAssetPrice);
        }
    }

    /**
     * @notice Post open oracle reporter prices, and recalculate stored price by comparing to anchor
     * @dev We let anyone pay to post anything, but only prices from configured reporter will be stored in the view.
     * @param symbols The symbols to compare to anchor for authoritative reading
     */
    function freshenPrices(string[] calldata symbols) external {
        // OLA_ADDITIONS : Using 'core asset price' instead of 'ethPrice
        uint referenceAssetPrice = fetchReferenceAssetPrice();

        // Try to update the view storage
        for (uint i = 0; i < symbols.length; i++) {
            postPriceInternal(symbols[i], referenceAssetPrice);
        }
    }

    /**
     * @notice Recalculates stored prices for all by comparing to anchor
     * @dev Only prices from configured UNISWAP will be recalculated in the view.
     */
    function freshensAllPrices() external {
        string[] memory symbols = autoPokingSymbols;
        // OLA_ADDITIONS : Using 'core asset price' instead of 'ethPrice
        uint referenceAssetPrice = fetchReferenceAssetPrice();

        // Try to update the view storage
        for (uint i = 0; i < symbols.length; i++) {
            postPriceInternal(symbols[i], referenceAssetPrice);
        }
    }

    function getAssetPriceInternal(address asset) internal view returns (uint) {
        TokenConfig memory config;

        config = getTokenConfigByUnderlying(asset);

        // Comptroller needs prices in the format: ${raw price} * 1e(36 - baseUnit)
        // Since the prices in this view have 6 decimals, we must scale them by 1e(36 - 6 - baseUnit)
        return mul(1e30, priceInternal(config)) / config.baseUnit;
    }

    function getAssetPriceUpdateTimestampInternal(address asset) internal view returns (uint) {
        TokenConfig memory config;

        config = getTokenConfigByUnderlying(asset);

        return pricesLastUpdate[config.symbolHash];
    }

    // OLA_ADDITIONS : Using 'referenceAssetPrice' instead of 'ethPrice'
    function postPriceInternal(string memory symbol, uint referenceAssetPrice) internal {
        TokenConfig memory config = getTokenConfigBySymbol(symbol);
        require(config.priceSource == PriceSource.REPORTER ||
                config.priceSource == PriceSource.UNISWAP ||
                config.priceSource == PriceSource.SIGNED_ONLY ||
                config.priceSource == PriceSource.ORACLE, "only reporter, uniswap, oracle or signed-only prices get posted");

        // OLA_ADDITIONS : Updating 'last price update timestamp' together with the prices
        uint lastUpdateTimestamp = block.timestamp;
        bytes32 symbolHash = keccak256(abi.encodePacked(symbol));

        if (referenceAssetHash == symbolHash) {
            prices[referenceAssetHash] = referenceAssetPrice;
            pricesLastUpdate[referenceAssetHash] = lastUpdateTimestamp;
        }

        // OLA_ADDITIONS : Support of 'signed-only' price posting
        // Signed-Only prices do not require 'anchorPrice' (which is taken from a pair)
        if (config.priceSource == PriceSource.SIGNED_ONLY) {
            uint reporterPrice = priceData.getPrice(reporter, symbol);

            prices[symbolHash] = reporterPrice;
            // OLA_ADDITIONS : Updating price timestamp
            pricesLastUpdate[symbolHash] = lastUpdateTimestamp;

            emit PriceUpdated(symbol, reporterPrice);

            return;
        }

        if (config.priceSource == PriceSource.ORACLE) {
            uint oraclePrice = getPriceFromOracle(config);
            prices[symbolHash] = oraclePrice;
            pricesLastUpdate[symbolHash] = lastUpdateTimestamp;
            emit PriceUpdated(symbol, oraclePrice);
        }


        uint anchorPrice;
        if (symbolHash == referenceAssetHash) {
            anchorPrice = referenceAssetPrice;
        } else {
            anchorPrice = fetchAnchorPrice(symbol, config, referenceAssetPrice);
        }


        if (config.priceSource == PriceSource.UNISWAP || reporterInvalidated) {
            prices[symbolHash] = anchorPrice;
            // OLA_ADDITIONS : Updating price timestamp
            pricesLastUpdate[symbolHash] = lastUpdateTimestamp;
            emit PriceUpdated(symbol, anchorPrice);
        } else {
            // OLA_ADDITIONS : Moves 'priceData.getPrice' inside to save gas on swap based asses
            uint reporterPrice = priceData.getPrice(reporter, symbol);
            if (isWithinAnchor(reporterPrice, anchorPrice)) {
                prices[symbolHash] = reporterPrice;
                // OLA_ADDITIONS : Updating price timestamp
                pricesLastUpdate[symbolHash] = lastUpdateTimestamp;
                emit PriceUpdated(symbol, reporterPrice);
            } else {
                emit PriceGuarded(symbol, reporterPrice, anchorPrice);
            }
        }
    }

    function isWithinAnchor(uint reporterPrice, uint anchorPrice) internal view returns (bool) {
        if (reporterPrice > 0) {
            uint anchorRatio = mul(anchorPrice, 100e16) / reporterPrice;
            return anchorRatio <= upperBoundAnchorRatio && anchorRatio >= lowerBoundAnchorRatio;
        }
        return false;
    }

    /**
     * @dev Fetches the current token/eth price accumulator from uniswap.
     */
    function currentCumulativePrice(TokenConfig memory config) internal view returns (uint) {
        (uint cumulativePrice0, uint cumulativePrice1,) = UniswapV2OracleLibrary.currentCumulativePrices(config.uniswapMarket);
        if (config.isUniswapReversed) {
            return cumulativePrice1;
        } else {
            return cumulativePrice0;
        }
    }

    /**
     * @dev Fetches the current eth/usd price from uniswap, with 6 decimals of precision.
     *  Conversion factor is 1e18 for eth/usdc market, since we decode uniswap price statically with 18 decimals.
     */
//    function fetchEthPrice() internal returns (uint) {
//        return fetchAnchorPrice("ETH", getTokenConfigBySymbolHash(ethHash), ethBaseUnit);
//    }

    function getPriceFromOracle(TokenConfig memory config) internal view returns (uint256 price) {
        price = RegistryForUAV(registry).getPriceForAsset(config.underlying);
        price = mul(price, 1e6);
        price = mul(price, config.baseUnit);
        price = price / 1e36;
    }

    /**
     * @dev Fetches the current core/usd price from uniswap, with 6 decimals of precision.
     *  Conversion factor is 1e18 for core/usdc market, since we decode uniswap price statically with 18 decimals.
     */
    function fetchReferenceAssetPrice() internal returns (uint) {
        uint256 price;
        TokenConfig memory config = getTokenConfigBySymbolHash(referenceAssetHash);

        if (PriceSource.REPORTER == config.priceSource || PriceSource.UNISWAP == config.priceSource) {
            price = fetchAnchorPrice(referenceAssetSymbol, config, ethBaseUnit);
        } else if (PriceSource.ORACLE == config.priceSource) {
            price = getPriceFromOracle(config);
        } else {
            price = priceData.getPrice(reporter, referenceAssetSymbol);
        }
        require(price != 0, "Reference asset price unavailable");
        
        return price;
    }

    /**
     * @dev Fetches the current token/usd price from uniswap, with 6 decimals of precision.
     * @param conversionFactor 1e18 if seeking the ETH price, and a 6 decimal ETH-USDC price in the case of other assets
     */
    function fetchAnchorPrice(string memory symbol, TokenConfig memory config, uint conversionFactor) internal virtual returns (uint) {
        (uint nowCumulativePrice, uint oldCumulativePrice, uint oldTimestamp) = pokeWindowValues(config);

        // This should be impossible, but better safe than sorry
        require(block.timestamp > oldTimestamp, "now must come after before");
        uint timeElapsed = block.timestamp - oldTimestamp;

        // Calculate uniswap time-weighted average price
        // Underflow is a property of the accumulators: https://uniswap.org/audit.html#orgc9b3190
        FixedPoint.uq112x112 memory priceAverage = FixedPoint.uq112x112(uint224((nowCumulativePrice - oldCumulativePrice) / timeElapsed));
        uint rawUniswapPriceMantissa = priceAverage.decode112with18();
        uint unscaledPriceMantissa = mul(rawUniswapPriceMantissa, conversionFactor);
        uint anchorPrice;

        // Adjust rawUniswapPrice according to the units of the non-ETH asset
        // In the case of ETH, we would have to scale by 1e6 / USDC_UNITS, but since baseUnit2 is 1e6 (USDC), it cancels

        // In the case of non-ETH tokens
        // a. pokeWindowValues already handled uniswap reversed cases, so priceAverage will always be Token/ETH TWAP price.
        // b. conversionFactor Scale = 1e(18 + 6 - tokenDecimals)). We assume that tokenDecimals is 18. If not, than probably there is a mistake here.
        // unscaledPriceMantissa = priceAverage(token/ETH TWAP price) * expScale * conversionFactor
        // so ->
        // anchorPrice = priceAverage * tokenBaseUnit / ethBaseUnit * ETH_price * 1e6
        //             = priceAverage * conversionFactor * tokenBaseUnit / ethBaseUnit
        //             = unscaledPriceMantissa / expScale * tokenBaseUnit / ethBaseUnit
        anchorPrice = mul(unscaledPriceMantissa, config.baseUnit) / ethBaseUnit / expScale;

        if (keccak256(abi.encodePacked(symbol)) == referenceAssetHash) {
            anchorPrice = mul(anchorPrice, 1e6) / usdBaseUnit;
        }

        emit AnchorPriceUpdated(symbol, anchorPrice, oldTimestamp, block.timestamp);

        return anchorPrice;
    }

    /**
     * @dev Get time-weighted average prices for a token at the current timestamp.
     *  Update new and old observations of lagging window if period elapsed.
     */
    function pokeWindowValues(TokenConfig memory config) internal returns (uint, uint, uint) {
        bytes32 symbolHash = config.symbolHash;
        uint cumulativePrice = currentCumulativePrice(config);

        Observation memory newObservation = newObservations[symbolHash];

        // Update new and old observations if elapsed time is greater than or equal to anchor period
        uint timeElapsed = block.timestamp - newObservation.timestamp;
        if (timeElapsed >= anchorPeriod) {
            oldObservations[symbolHash].timestamp = newObservation.timestamp;
            oldObservations[symbolHash].acc = newObservation.acc;

            newObservations[symbolHash].timestamp = block.timestamp;
            newObservations[symbolHash].acc = cumulativePrice;
            emit UniswapWindowUpdated(config.symbolHash, newObservation.timestamp, block.timestamp, newObservation.acc, cumulativePrice);
        }
        return (cumulativePrice, oldObservations[symbolHash].acc, oldObservations[symbolHash].timestamp);
    }

    /**
     * @notice Invalidate the reporter, and fall back to using anchor directly in all cases
     * @dev Only the reporter may sign a message which allows it to invalidate itself.
     *  To be used in cases of emergency, if the reporter thinks their key may be compromised.
     * @param message The data that was presumably signed
     * @param signature The fingerprint of the data + private key
     */
    function invalidateReporter(bytes memory message, bytes memory signature) external {
        (string memory decodedMessage, ) = abi.decode(message, (string, address));
        require(keccak256(abi.encodePacked(decodedMessage)) == rotateHash, "invalid message must be 'rotate'");
        require(source(message, signature) == reporter, "invalidation message must come from the reporter");
        reporterInvalidated = true;
        emit ReporterInvalidated(reporter);
    }

    /**
     * @notice Recovers the source address which signed a message
     * @dev Comparing to a claimed address would add nothing,
     *  as the caller could simply perform the recover and claim that address.
     * @param message The data that was presumably signed
     * @param signature The fingerprint of the data + private key
     * @return The source address which signed the message, presumably
     */
    function source(bytes memory message, bytes memory signature) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = abi.decode(signature, (bytes32, bytes32, uint8));
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(message)));
        return ecrecover(hash, v, r, s);
    }

    /// @dev Overflow proof multiplication
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) return 0;
        uint c = a * b;
        require(c / a == b, "multiplication overflow");
        return c;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.6;

import "./OpenOracleData.sol";

/**
 * @title The Open Oracle Price Data Contract
 * @notice Values stored in this contract should represent a USD price with 6 decimals precision
 * @author Compound Labs, Inc.
 */
contract OpenOraclePriceData is OpenOracleData {
    ///@notice The event emitted when a source writes to its storage
    event Write(address indexed source, string key, uint64 timestamp, uint64 value);
    ///@notice The event emitted when the timestamp on a price is invalid and it is not written to storage
    event NotWritten(uint64 priorTimestamp, uint256 messageTimestamp, uint256 blockTimestamp);

    ///@notice The fundamental unit of storage for a reporter source
    struct Datum {
        uint64 timestamp;
        uint64 value;
    }

    /**
     * @dev The most recent authenticated data from all sources.
     *  This is private because dynamic mapping keys preclude auto-generated getters.
     */
    mapping(address => mapping(string => Datum)) private data;

    /**
     * @notice Write a bunch of signed datum to the authenticated storage mapping
     * @param message The payload containing the timestamp, and (key, value) pairs
     * @param signature The cryptographic signature of the message payload, authorizing the source to write
     * @return The keys that were written
     */
    function put(bytes calldata message, bytes calldata signature) external returns (string memory) {
        (address source, uint64 timestamp, string memory key, uint64 value) = decodeMessage(message, signature);
        return putInternal(source, timestamp, key, value);
    }

    function putInternal(address source, uint64 timestamp, string memory key, uint64 value) internal returns (string memory) {
        // Only update if newer than stored, according to source
        Datum storage prior = data[source][key];
        if (timestamp > prior.timestamp && timestamp < block.timestamp + 60 minutes && source != address(0)) {
            data[source][key] = Datum(timestamp, value);
            emit Write(source, key, timestamp, value);
        } else {
            emit NotWritten(prior.timestamp, timestamp, block.timestamp);
        }
        return key;
    }

    function decodeMessage(bytes calldata message, bytes calldata signature) internal returns (address, uint64, string memory, uint64) {
        // Recover the source address
        address source = source(message, signature);

        // Decode the message and check the kind
        (string memory kind, uint64 timestamp, string memory key, uint64 value) = abi.decode(message, (string, uint64, string, uint64));
        require(keccak256(abi.encodePacked(kind)) == keccak256(abi.encodePacked("prices")), "Kind of data must be 'prices'");
        return (source, timestamp, key, value);
    }

    /**
     * @notice Read a single key from an authenticated source
     * @param source The verifiable author of the data
     * @param key The selector for the value to return
     * @return The claimed Unix timestamp for the data and the price value (defaults to (0, 0))
     */
    function get(address source, string calldata key) external view returns (uint64, uint64) {
        Datum storage datum = data[source][key];
        return (datum.timestamp, datum.value);
    }

    /**
     * @notice Read only the value for a single key from an authenticated source
     * @param source The verifiable author of the data
     * @param key The selector for the value to return
     * @return The price value (defaults to 0)
     */
    function getPrice(address source, string calldata key) external view returns (uint64) {
        return data[source][key].value;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

interface CErc20ForUniswapConfig {
    function underlying() external view returns (address);
}

contract UniswapConfig {
    /// @dev Describe how to interpret the fixedPrice in the TokenConfig.
    enum PriceSource {
        FIXED_ETH, /// implies the fixedPrice is a constant multiple of the ETH price (which varies)
        FIXED_USD, /// implies the fixedPrice is a constant multiple of the USD price (which is 1)
        REPORTER,   /// implies the price is set by the reporter
        UNISWAP,     /// implies the price is set by uniswap
        SIGNED_ONLY, /// implies the price is set by a reporter without a matching pair
        ORACLE       /// implies the price is being fetched from an oracle
    }
    
    /// @dev Describe how the USD price should be determined for an asset.
    ///  There should be 1 TokenConfig object for each supported asset, passed in the constructor.
    struct TokenConfig {
        address underlying;
        bytes32 symbolHash;
        uint256 baseUnit;
        PriceSource priceSource;
        uint256 fixedPrice;
        address uniswapMarket;
        bool isUniswapReversed;
    }

    /// @notice The max number of tokens this contract is hardcoded to support
    /// @dev Do not change this variable without updating all the fields throughout the contract.
    uint public constant maxTokens = 30;

    /// @notice The number of tokens this contract actually supports
    uint public immutable numTokens;

    address internal immutable underlying00;
    address internal immutable underlying01;
    address internal immutable underlying02;
    address internal immutable underlying03;
    address internal immutable underlying04;
    address internal immutable underlying05;
    address internal immutable underlying06;
    address internal immutable underlying07;
    address internal immutable underlying08;
    address internal immutable underlying09;
    address internal immutable underlying10;
    address internal immutable underlying11;
    address internal immutable underlying12;
    address internal immutable underlying13;
    address internal immutable underlying14;
    address internal immutable underlying15;
    address internal immutable underlying16;
    address internal immutable underlying17;
    address internal immutable underlying18;
    address internal immutable underlying19;
    address internal immutable underlying20;
    address internal immutable underlying21;
    address internal immutable underlying22;
    address internal immutable underlying23;
    address internal immutable underlying24;
    address internal immutable underlying25;
    address internal immutable underlying26;
    address internal immutable underlying27;
    address internal immutable underlying28;
    address internal immutable underlying29;

    bytes32 internal immutable symbolHash00;
    bytes32 internal immutable symbolHash01;
    bytes32 internal immutable symbolHash02;
    bytes32 internal immutable symbolHash03;
    bytes32 internal immutable symbolHash04;
    bytes32 internal immutable symbolHash05;
    bytes32 internal immutable symbolHash06;
    bytes32 internal immutable symbolHash07;
    bytes32 internal immutable symbolHash08;
    bytes32 internal immutable symbolHash09;
    bytes32 internal immutable symbolHash10;
    bytes32 internal immutable symbolHash11;
    bytes32 internal immutable symbolHash12;
    bytes32 internal immutable symbolHash13;
    bytes32 internal immutable symbolHash14;
    bytes32 internal immutable symbolHash15;
    bytes32 internal immutable symbolHash16;
    bytes32 internal immutable symbolHash17;
    bytes32 internal immutable symbolHash18;
    bytes32 internal immutable symbolHash19;
    bytes32 internal immutable symbolHash20;
    bytes32 internal immutable symbolHash21;
    bytes32 internal immutable symbolHash22;
    bytes32 internal immutable symbolHash23;
    bytes32 internal immutable symbolHash24;
    bytes32 internal immutable symbolHash25;
    bytes32 internal immutable symbolHash26;
    bytes32 internal immutable symbolHash27;
    bytes32 internal immutable symbolHash28;
    bytes32 internal immutable symbolHash29;

    uint256 internal immutable baseUnit00;
    uint256 internal immutable baseUnit01;
    uint256 internal immutable baseUnit02;
    uint256 internal immutable baseUnit03;
    uint256 internal immutable baseUnit04;
    uint256 internal immutable baseUnit05;
    uint256 internal immutable baseUnit06;
    uint256 internal immutable baseUnit07;
    uint256 internal immutable baseUnit08;
    uint256 internal immutable baseUnit09;
    uint256 internal immutable baseUnit10;
    uint256 internal immutable baseUnit11;
    uint256 internal immutable baseUnit12;
    uint256 internal immutable baseUnit13;
    uint256 internal immutable baseUnit14;
    uint256 internal immutable baseUnit15;
    uint256 internal immutable baseUnit16;
    uint256 internal immutable baseUnit17;
    uint256 internal immutable baseUnit18;
    uint256 internal immutable baseUnit19;
    uint256 internal immutable baseUnit20;
    uint256 internal immutable baseUnit21;
    uint256 internal immutable baseUnit22;
    uint256 internal immutable baseUnit23;
    uint256 internal immutable baseUnit24;
    uint256 internal immutable baseUnit25;
    uint256 internal immutable baseUnit26;
    uint256 internal immutable baseUnit27;
    uint256 internal immutable baseUnit28;
    uint256 internal immutable baseUnit29;

    PriceSource internal immutable priceSource00;
    PriceSource internal immutable priceSource01;
    PriceSource internal immutable priceSource02;
    PriceSource internal immutable priceSource03;
    PriceSource internal immutable priceSource04;
    PriceSource internal immutable priceSource05;
    PriceSource internal immutable priceSource06;
    PriceSource internal immutable priceSource07;
    PriceSource internal immutable priceSource08;
    PriceSource internal immutable priceSource09;
    PriceSource internal immutable priceSource10;
    PriceSource internal immutable priceSource11;
    PriceSource internal immutable priceSource12;
    PriceSource internal immutable priceSource13;
    PriceSource internal immutable priceSource14;
    PriceSource internal immutable priceSource15;
    PriceSource internal immutable priceSource16;
    PriceSource internal immutable priceSource17;
    PriceSource internal immutable priceSource18;
    PriceSource internal immutable priceSource19;
    PriceSource internal immutable priceSource20;
    PriceSource internal immutable priceSource21;
    PriceSource internal immutable priceSource22;
    PriceSource internal immutable priceSource23;
    PriceSource internal immutable priceSource24;
    PriceSource internal immutable priceSource25;
    PriceSource internal immutable priceSource26;
    PriceSource internal immutable priceSource27;
    PriceSource internal immutable priceSource28;
    PriceSource internal immutable priceSource29;

    uint256 internal immutable fixedPrice00;
    uint256 internal immutable fixedPrice01;
    uint256 internal immutable fixedPrice02;
    uint256 internal immutable fixedPrice03;
    uint256 internal immutable fixedPrice04;
    uint256 internal immutable fixedPrice05;
    uint256 internal immutable fixedPrice06;
    uint256 internal immutable fixedPrice07;
    uint256 internal immutable fixedPrice08;
    uint256 internal immutable fixedPrice09;
    uint256 internal immutable fixedPrice10;
    uint256 internal immutable fixedPrice11;
    uint256 internal immutable fixedPrice12;
    uint256 internal immutable fixedPrice13;
    uint256 internal immutable fixedPrice14;
    uint256 internal immutable fixedPrice15;
    uint256 internal immutable fixedPrice16;
    uint256 internal immutable fixedPrice17;
    uint256 internal immutable fixedPrice18;
    uint256 internal immutable fixedPrice19;
    uint256 internal immutable fixedPrice20;
    uint256 internal immutable fixedPrice21;
    uint256 internal immutable fixedPrice22;
    uint256 internal immutable fixedPrice23;
    uint256 internal immutable fixedPrice24;
    uint256 internal immutable fixedPrice25;
    uint256 internal immutable fixedPrice26;
    uint256 internal immutable fixedPrice27;
    uint256 internal immutable fixedPrice28;
    uint256 internal immutable fixedPrice29;

    address internal immutable uniswapMarket00;
    address internal immutable uniswapMarket01;
    address internal immutable uniswapMarket02;
    address internal immutable uniswapMarket03;
    address internal immutable uniswapMarket04;
    address internal immutable uniswapMarket05;
    address internal immutable uniswapMarket06;
    address internal immutable uniswapMarket07;
    address internal immutable uniswapMarket08;
    address internal immutable uniswapMarket09;
    address internal immutable uniswapMarket10;
    address internal immutable uniswapMarket11;
    address internal immutable uniswapMarket12;
    address internal immutable uniswapMarket13;
    address internal immutable uniswapMarket14;
    address internal immutable uniswapMarket15;
    address internal immutable uniswapMarket16;
    address internal immutable uniswapMarket17;
    address internal immutable uniswapMarket18;
    address internal immutable uniswapMarket19;
    address internal immutable uniswapMarket20;
    address internal immutable uniswapMarket21;
    address internal immutable uniswapMarket22;
    address internal immutable uniswapMarket23;
    address internal immutable uniswapMarket24;
    address internal immutable uniswapMarket25;
    address internal immutable uniswapMarket26;
    address internal immutable uniswapMarket27;
    address internal immutable uniswapMarket28;
    address internal immutable uniswapMarket29;

    bool internal immutable isUniswapReversed00;
    bool internal immutable isUniswapReversed01;
    bool internal immutable isUniswapReversed02;
    bool internal immutable isUniswapReversed03;
    bool internal immutable isUniswapReversed04;
    bool internal immutable isUniswapReversed05;
    bool internal immutable isUniswapReversed06;
    bool internal immutable isUniswapReversed07;
    bool internal immutable isUniswapReversed08;
    bool internal immutable isUniswapReversed09;
    bool internal immutable isUniswapReversed10;
    bool internal immutable isUniswapReversed11;
    bool internal immutable isUniswapReversed12;
    bool internal immutable isUniswapReversed13;
    bool internal immutable isUniswapReversed14;
    bool internal immutable isUniswapReversed15;
    bool internal immutable isUniswapReversed16;
    bool internal immutable isUniswapReversed17;
    bool internal immutable isUniswapReversed18;
    bool internal immutable isUniswapReversed19;
    bool internal immutable isUniswapReversed20;
    bool internal immutable isUniswapReversed21;
    bool internal immutable isUniswapReversed22;
    bool internal immutable isUniswapReversed23;
    bool internal immutable isUniswapReversed24;
    bool internal immutable isUniswapReversed25;
    bool internal immutable isUniswapReversed26;
    bool internal immutable isUniswapReversed27;
    bool internal immutable isUniswapReversed28;
    bool internal immutable isUniswapReversed29;

    /**
     * @notice Construct an immutable store of configs into the contract data
     * @param configs The configs for the supported assets
     */
    constructor(TokenConfig[] memory configs) public {
        require(configs.length <= maxTokens, "too many configs");
        numTokens = configs.length;

        underlying00 = get(configs, 0).underlying;
        underlying01 = get(configs, 1).underlying;
        underlying02 = get(configs, 2).underlying;
        underlying03 = get(configs, 3).underlying;
        underlying04 = get(configs, 4).underlying;
        underlying05 = get(configs, 5).underlying;
        underlying06 = get(configs, 6).underlying;
        underlying07 = get(configs, 7).underlying;
        underlying08 = get(configs, 8).underlying;
        underlying09 = get(configs, 9).underlying;
        underlying10 = get(configs, 10).underlying;
        underlying11 = get(configs, 11).underlying;
        underlying12 = get(configs, 12).underlying;
        underlying13 = get(configs, 13).underlying;
        underlying14 = get(configs, 14).underlying;
        underlying15 = get(configs, 15).underlying;
        underlying16 = get(configs, 16).underlying;
        underlying17 = get(configs, 17).underlying;
        underlying18 = get(configs, 18).underlying;
        underlying19 = get(configs, 19).underlying;
        underlying20 = get(configs, 20).underlying;
        underlying21 = get(configs, 21).underlying;
        underlying22 = get(configs, 22).underlying;
        underlying23 = get(configs, 23).underlying;
        underlying24 = get(configs, 24).underlying;
        underlying25 = get(configs, 25).underlying;
        underlying26 = get(configs, 26).underlying;
        underlying27 = get(configs, 27).underlying;
        underlying28 = get(configs, 28).underlying;
        underlying29 = get(configs, 29).underlying;

        symbolHash00 = get(configs, 0).symbolHash;
        symbolHash01 = get(configs, 1).symbolHash;
        symbolHash02 = get(configs, 2).symbolHash;
        symbolHash03 = get(configs, 3).symbolHash;
        symbolHash04 = get(configs, 4).symbolHash;
        symbolHash05 = get(configs, 5).symbolHash;
        symbolHash06 = get(configs, 6).symbolHash;
        symbolHash07 = get(configs, 7).symbolHash;
        symbolHash08 = get(configs, 8).symbolHash;
        symbolHash09 = get(configs, 9).symbolHash;
        symbolHash10 = get(configs, 10).symbolHash;
        symbolHash11 = get(configs, 11).symbolHash;
        symbolHash12 = get(configs, 12).symbolHash;
        symbolHash13 = get(configs, 13).symbolHash;
        symbolHash14 = get(configs, 14).symbolHash;
        symbolHash15 = get(configs, 15).symbolHash;
        symbolHash16 = get(configs, 16).symbolHash;
        symbolHash17 = get(configs, 17).symbolHash;
        symbolHash18 = get(configs, 18).symbolHash;
        symbolHash19 = get(configs, 19).symbolHash;
        symbolHash20 = get(configs, 20).symbolHash;
        symbolHash21 = get(configs, 21).symbolHash;
        symbolHash22 = get(configs, 22).symbolHash;
        symbolHash23 = get(configs, 23).symbolHash;
        symbolHash24 = get(configs, 24).symbolHash;
        symbolHash25 = get(configs, 25).symbolHash;
        symbolHash26 = get(configs, 26).symbolHash;
        symbolHash27 = get(configs, 27).symbolHash;
        symbolHash28 = get(configs, 28).symbolHash;
        symbolHash29 = get(configs, 29).symbolHash;

        baseUnit00 = get(configs, 0).baseUnit;
        baseUnit01 = get(configs, 1).baseUnit;
        baseUnit02 = get(configs, 2).baseUnit;
        baseUnit03 = get(configs, 3).baseUnit;
        baseUnit04 = get(configs, 4).baseUnit;
        baseUnit05 = get(configs, 5).baseUnit;
        baseUnit06 = get(configs, 6).baseUnit;
        baseUnit07 = get(configs, 7).baseUnit;
        baseUnit08 = get(configs, 8).baseUnit;
        baseUnit09 = get(configs, 9).baseUnit;
        baseUnit10 = get(configs, 10).baseUnit;
        baseUnit11 = get(configs, 11).baseUnit;
        baseUnit12 = get(configs, 12).baseUnit;
        baseUnit13 = get(configs, 13).baseUnit;
        baseUnit14 = get(configs, 14).baseUnit;
        baseUnit15 = get(configs, 15).baseUnit;
        baseUnit16 = get(configs, 16).baseUnit;
        baseUnit17 = get(configs, 17).baseUnit;
        baseUnit18 = get(configs, 18).baseUnit;
        baseUnit19 = get(configs, 19).baseUnit;
        baseUnit20 = get(configs, 20).baseUnit;
        baseUnit21 = get(configs, 21).baseUnit;
        baseUnit22 = get(configs, 22).baseUnit;
        baseUnit23 = get(configs, 23).baseUnit;
        baseUnit24 = get(configs, 24).baseUnit;
        baseUnit25 = get(configs, 25).baseUnit;
        baseUnit26 = get(configs, 26).baseUnit;
        baseUnit27 = get(configs, 27).baseUnit;
        baseUnit28 = get(configs, 28).baseUnit;
        baseUnit29 = get(configs, 29).baseUnit;

        priceSource00 = get(configs, 0).priceSource;
        priceSource01 = get(configs, 1).priceSource;
        priceSource02 = get(configs, 2).priceSource;
        priceSource03 = get(configs, 3).priceSource;
        priceSource04 = get(configs, 4).priceSource;
        priceSource05 = get(configs, 5).priceSource;
        priceSource06 = get(configs, 6).priceSource;
        priceSource07 = get(configs, 7).priceSource;
        priceSource08 = get(configs, 8).priceSource;
        priceSource09 = get(configs, 9).priceSource;
        priceSource10 = get(configs, 10).priceSource;
        priceSource11 = get(configs, 11).priceSource;
        priceSource12 = get(configs, 12).priceSource;
        priceSource13 = get(configs, 13).priceSource;
        priceSource14 = get(configs, 14).priceSource;
        priceSource15 = get(configs, 15).priceSource;
        priceSource16 = get(configs, 16).priceSource;
        priceSource17 = get(configs, 17).priceSource;
        priceSource18 = get(configs, 18).priceSource;
        priceSource19 = get(configs, 19).priceSource;
        priceSource20 = get(configs, 20).priceSource;
        priceSource21 = get(configs, 21).priceSource;
        priceSource22 = get(configs, 22).priceSource;
        priceSource23 = get(configs, 23).priceSource;
        priceSource24 = get(configs, 24).priceSource;
        priceSource25 = get(configs, 25).priceSource;
        priceSource26 = get(configs, 26).priceSource;
        priceSource27 = get(configs, 27).priceSource;
        priceSource28 = get(configs, 28).priceSource;
        priceSource29 = get(configs, 29).priceSource;

        fixedPrice00 = get(configs, 0).fixedPrice;
        fixedPrice01 = get(configs, 1).fixedPrice;
        fixedPrice02 = get(configs, 2).fixedPrice;
        fixedPrice03 = get(configs, 3).fixedPrice;
        fixedPrice04 = get(configs, 4).fixedPrice;
        fixedPrice05 = get(configs, 5).fixedPrice;
        fixedPrice06 = get(configs, 6).fixedPrice;
        fixedPrice07 = get(configs, 7).fixedPrice;
        fixedPrice08 = get(configs, 8).fixedPrice;
        fixedPrice09 = get(configs, 9).fixedPrice;
        fixedPrice10 = get(configs, 10).fixedPrice;
        fixedPrice11 = get(configs, 11).fixedPrice;
        fixedPrice12 = get(configs, 12).fixedPrice;
        fixedPrice13 = get(configs, 13).fixedPrice;
        fixedPrice14 = get(configs, 14).fixedPrice;
        fixedPrice15 = get(configs, 15).fixedPrice;
        fixedPrice16 = get(configs, 16).fixedPrice;
        fixedPrice17 = get(configs, 17).fixedPrice;
        fixedPrice18 = get(configs, 18).fixedPrice;
        fixedPrice19 = get(configs, 19).fixedPrice;
        fixedPrice20 = get(configs, 20).fixedPrice;
        fixedPrice21 = get(configs, 21).fixedPrice;
        fixedPrice22 = get(configs, 22).fixedPrice;
        fixedPrice23 = get(configs, 23).fixedPrice;
        fixedPrice24 = get(configs, 24).fixedPrice;
        fixedPrice25 = get(configs, 25).fixedPrice;
        fixedPrice26 = get(configs, 26).fixedPrice;
        fixedPrice27 = get(configs, 27).fixedPrice;
        fixedPrice28 = get(configs, 28).fixedPrice;
        fixedPrice29 = get(configs, 29).fixedPrice;

        uniswapMarket00 = get(configs, 0).uniswapMarket;
        uniswapMarket01 = get(configs, 1).uniswapMarket;
        uniswapMarket02 = get(configs, 2).uniswapMarket;
        uniswapMarket03 = get(configs, 3).uniswapMarket;
        uniswapMarket04 = get(configs, 4).uniswapMarket;
        uniswapMarket05 = get(configs, 5).uniswapMarket;
        uniswapMarket06 = get(configs, 6).uniswapMarket;
        uniswapMarket07 = get(configs, 7).uniswapMarket;
        uniswapMarket08 = get(configs, 8).uniswapMarket;
        uniswapMarket09 = get(configs, 9).uniswapMarket;
        uniswapMarket10 = get(configs, 10).uniswapMarket;
        uniswapMarket11 = get(configs, 11).uniswapMarket;
        uniswapMarket12 = get(configs, 12).uniswapMarket;
        uniswapMarket13 = get(configs, 13).uniswapMarket;
        uniswapMarket14 = get(configs, 14).uniswapMarket;
        uniswapMarket15 = get(configs, 15).uniswapMarket;
        uniswapMarket16 = get(configs, 16).uniswapMarket;
        uniswapMarket17 = get(configs, 17).uniswapMarket;
        uniswapMarket18 = get(configs, 18).uniswapMarket;
        uniswapMarket19 = get(configs, 19).uniswapMarket;
        uniswapMarket20 = get(configs, 20).uniswapMarket;
        uniswapMarket21 = get(configs, 21).uniswapMarket;
        uniswapMarket22 = get(configs, 22).uniswapMarket;
        uniswapMarket23 = get(configs, 23).uniswapMarket;
        uniswapMarket24 = get(configs, 24).uniswapMarket;
        uniswapMarket25 = get(configs, 25).uniswapMarket;
        uniswapMarket26 = get(configs, 26).uniswapMarket;
        uniswapMarket27 = get(configs, 27).uniswapMarket;
        uniswapMarket28 = get(configs, 28).uniswapMarket;
        uniswapMarket29 = get(configs, 29).uniswapMarket;

        isUniswapReversed00 = get(configs, 0).isUniswapReversed;
        isUniswapReversed01 = get(configs, 1).isUniswapReversed;
        isUniswapReversed02 = get(configs, 2).isUniswapReversed;
        isUniswapReversed03 = get(configs, 3).isUniswapReversed;
        isUniswapReversed04 = get(configs, 4).isUniswapReversed;
        isUniswapReversed05 = get(configs, 5).isUniswapReversed;
        isUniswapReversed06 = get(configs, 6).isUniswapReversed;
        isUniswapReversed07 = get(configs, 7).isUniswapReversed;
        isUniswapReversed08 = get(configs, 8).isUniswapReversed;
        isUniswapReversed09 = get(configs, 9).isUniswapReversed;
        isUniswapReversed10 = get(configs, 10).isUniswapReversed;
        isUniswapReversed11 = get(configs, 11).isUniswapReversed;
        isUniswapReversed12 = get(configs, 12).isUniswapReversed;
        isUniswapReversed13 = get(configs, 13).isUniswapReversed;
        isUniswapReversed14 = get(configs, 14).isUniswapReversed;
        isUniswapReversed15 = get(configs, 15).isUniswapReversed;
        isUniswapReversed16 = get(configs, 16).isUniswapReversed;
        isUniswapReversed17 = get(configs, 17).isUniswapReversed;
        isUniswapReversed18 = get(configs, 18).isUniswapReversed;
        isUniswapReversed19 = get(configs, 19).isUniswapReversed;
        isUniswapReversed20 = get(configs, 20).isUniswapReversed;
        isUniswapReversed21 = get(configs, 21).isUniswapReversed;
        isUniswapReversed22 = get(configs, 22).isUniswapReversed;
        isUniswapReversed23 = get(configs, 23).isUniswapReversed;
        isUniswapReversed24 = get(configs, 24).isUniswapReversed;
        isUniswapReversed25 = get(configs, 25).isUniswapReversed;
        isUniswapReversed26 = get(configs, 26).isUniswapReversed;
        isUniswapReversed27 = get(configs, 27).isUniswapReversed;
        isUniswapReversed28 = get(configs, 28).isUniswapReversed;
        isUniswapReversed29 = get(configs, 29).isUniswapReversed;
    }

    function get(TokenConfig[] memory configs, uint i) internal pure returns (TokenConfig memory) {
        if (i < configs.length)
            return configs[i];
        return TokenConfig({
            underlying: address(0),
            symbolHash: bytes32(0),
            baseUnit: uint256(0),
            priceSource: PriceSource(0),
            fixedPrice: uint256(0),
            uniswapMarket: address(0),
            isUniswapReversed: false
        });
    }

    function getUnderlyingIndex(address underlying) internal view returns (uint) {
        if (underlying == underlying00) return 0;
        if (underlying == underlying01) return 1;
        if (underlying == underlying02) return 2;
        if (underlying == underlying03) return 3;
        if (underlying == underlying04) return 4;
        if (underlying == underlying05) return 5;
        if (underlying == underlying06) return 6;
        if (underlying == underlying07) return 7;
        if (underlying == underlying08) return 8;
        if (underlying == underlying09) return 9;
        if (underlying == underlying10) return 10;
        if (underlying == underlying11) return 11;
        if (underlying == underlying12) return 12;
        if (underlying == underlying13) return 13;
        if (underlying == underlying14) return 14;
        if (underlying == underlying15) return 15;
        if (underlying == underlying16) return 16;
        if (underlying == underlying17) return 17;
        if (underlying == underlying18) return 18;
        if (underlying == underlying19) return 19;
        if (underlying == underlying20) return 20;
        if (underlying == underlying21) return 21;
        if (underlying == underlying22) return 22;
        if (underlying == underlying23) return 23;
        if (underlying == underlying24) return 24;
        if (underlying == underlying25) return 25;
        if (underlying == underlying26) return 26;
        if (underlying == underlying27) return 27;
        if (underlying == underlying28) return 28;
        if (underlying == underlying29) return 29;

        return uint(-1);
    }

    function getSymbolHashIndex(bytes32 symbolHash) internal view returns (uint) {
        if (symbolHash == symbolHash00) return 0;
        if (symbolHash == symbolHash01) return 1;
        if (symbolHash == symbolHash02) return 2;
        if (symbolHash == symbolHash03) return 3;
        if (symbolHash == symbolHash04) return 4;
        if (symbolHash == symbolHash05) return 5;
        if (symbolHash == symbolHash06) return 6;
        if (symbolHash == symbolHash07) return 7;
        if (symbolHash == symbolHash08) return 8;
        if (symbolHash == symbolHash09) return 9;
        if (symbolHash == symbolHash10) return 10;
        if (symbolHash == symbolHash11) return 11;
        if (symbolHash == symbolHash12) return 12;
        if (symbolHash == symbolHash13) return 13;
        if (symbolHash == symbolHash14) return 14;
        if (symbolHash == symbolHash15) return 15;
        if (symbolHash == symbolHash16) return 16;
        if (symbolHash == symbolHash17) return 17;
        if (symbolHash == symbolHash18) return 18;
        if (symbolHash == symbolHash19) return 19;
        if (symbolHash == symbolHash20) return 20;
        if (symbolHash == symbolHash21) return 21;
        if (symbolHash == symbolHash22) return 22;
        if (symbolHash == symbolHash23) return 23;
        if (symbolHash == symbolHash24) return 24;
        if (symbolHash == symbolHash25) return 25;
        if (symbolHash == symbolHash26) return 26;
        if (symbolHash == symbolHash27) return 27;
        if (symbolHash == symbolHash28) return 28;
        if (symbolHash == symbolHash29) return 29;

        return uint(-1);
    }

    /**
     * @notice Get the i-th config, according to the order they were passed in originally
     * @param i The index of the config to get
     * @return The config object
     */
    function getTokenConfig(uint i) public view returns (TokenConfig memory) {
        require(i < numTokens, "token config not found");

        if (i == 1) return TokenConfig({underlying: underlying01, symbolHash: symbolHash01, baseUnit: baseUnit01, priceSource: priceSource01, fixedPrice: fixedPrice01, uniswapMarket: uniswapMarket01, isUniswapReversed: isUniswapReversed01});
        if (i == 0) return TokenConfig({underlying: underlying00, symbolHash: symbolHash00, baseUnit: baseUnit00, priceSource: priceSource00, fixedPrice: fixedPrice00, uniswapMarket: uniswapMarket00, isUniswapReversed: isUniswapReversed00});
        if (i == 2) return TokenConfig({underlying: underlying02, symbolHash: symbolHash02, baseUnit: baseUnit02, priceSource: priceSource02, fixedPrice: fixedPrice02, uniswapMarket: uniswapMarket02, isUniswapReversed: isUniswapReversed02});
        if (i == 3) return TokenConfig({underlying: underlying03, symbolHash: symbolHash03, baseUnit: baseUnit03, priceSource: priceSource03, fixedPrice: fixedPrice03, uniswapMarket: uniswapMarket03, isUniswapReversed: isUniswapReversed03});
        if (i == 4) return TokenConfig({underlying: underlying04, symbolHash: symbolHash04, baseUnit: baseUnit04, priceSource: priceSource04, fixedPrice: fixedPrice04, uniswapMarket: uniswapMarket04, isUniswapReversed: isUniswapReversed04});
        if (i == 5) return TokenConfig({underlying: underlying05, symbolHash: symbolHash05, baseUnit: baseUnit05, priceSource: priceSource05, fixedPrice: fixedPrice05, uniswapMarket: uniswapMarket05, isUniswapReversed: isUniswapReversed05});
        if (i == 6) return TokenConfig({underlying: underlying06, symbolHash: symbolHash06, baseUnit: baseUnit06, priceSource: priceSource06, fixedPrice: fixedPrice06, uniswapMarket: uniswapMarket06, isUniswapReversed: isUniswapReversed06});
        if (i == 7) return TokenConfig({underlying: underlying07, symbolHash: symbolHash07, baseUnit: baseUnit07, priceSource: priceSource07, fixedPrice: fixedPrice07, uniswapMarket: uniswapMarket07, isUniswapReversed: isUniswapReversed07});
        if (i == 8) return TokenConfig({underlying: underlying08, symbolHash: symbolHash08, baseUnit: baseUnit08, priceSource: priceSource08, fixedPrice: fixedPrice08, uniswapMarket: uniswapMarket08, isUniswapReversed: isUniswapReversed08});
        if (i == 9) return TokenConfig({underlying: underlying09, symbolHash: symbolHash09, baseUnit: baseUnit09, priceSource: priceSource09, fixedPrice: fixedPrice09, uniswapMarket: uniswapMarket09, isUniswapReversed: isUniswapReversed09});

        if (i == 10) return TokenConfig({underlying: underlying10, symbolHash: symbolHash10, baseUnit: baseUnit10, priceSource: priceSource10, fixedPrice: fixedPrice10, uniswapMarket: uniswapMarket10, isUniswapReversed: isUniswapReversed10});
        if (i == 11) return TokenConfig({underlying: underlying11, symbolHash: symbolHash11, baseUnit: baseUnit11, priceSource: priceSource11, fixedPrice: fixedPrice11, uniswapMarket: uniswapMarket11, isUniswapReversed: isUniswapReversed11});
        if (i == 12) return TokenConfig({underlying: underlying12, symbolHash: symbolHash12, baseUnit: baseUnit12, priceSource: priceSource12, fixedPrice: fixedPrice12, uniswapMarket: uniswapMarket12, isUniswapReversed: isUniswapReversed12});
        if (i == 13) return TokenConfig({underlying: underlying13, symbolHash: symbolHash13, baseUnit: baseUnit13, priceSource: priceSource13, fixedPrice: fixedPrice13, uniswapMarket: uniswapMarket13, isUniswapReversed: isUniswapReversed13});
        if (i == 14) return TokenConfig({underlying: underlying14, symbolHash: symbolHash14, baseUnit: baseUnit14, priceSource: priceSource14, fixedPrice: fixedPrice14, uniswapMarket: uniswapMarket14, isUniswapReversed: isUniswapReversed14});
        if (i == 15) return TokenConfig({underlying: underlying15, symbolHash: symbolHash15, baseUnit: baseUnit15, priceSource: priceSource15, fixedPrice: fixedPrice15, uniswapMarket: uniswapMarket15, isUniswapReversed: isUniswapReversed15});
        if (i == 16) return TokenConfig({underlying: underlying16, symbolHash: symbolHash16, baseUnit: baseUnit16, priceSource: priceSource16, fixedPrice: fixedPrice16, uniswapMarket: uniswapMarket16, isUniswapReversed: isUniswapReversed16});
        if (i == 17) return TokenConfig({underlying: underlying17, symbolHash: symbolHash17, baseUnit: baseUnit17, priceSource: priceSource17, fixedPrice: fixedPrice17, uniswapMarket: uniswapMarket17, isUniswapReversed: isUniswapReversed17});
        if (i == 18) return TokenConfig({underlying: underlying18, symbolHash: symbolHash18, baseUnit: baseUnit18, priceSource: priceSource18, fixedPrice: fixedPrice18, uniswapMarket: uniswapMarket18, isUniswapReversed: isUniswapReversed18});
        if (i == 19) return TokenConfig({underlying: underlying19, symbolHash: symbolHash19, baseUnit: baseUnit19, priceSource: priceSource19, fixedPrice: fixedPrice19, uniswapMarket: uniswapMarket19, isUniswapReversed: isUniswapReversed19});

        if (i == 20) return TokenConfig({underlying: underlying20, symbolHash: symbolHash20, baseUnit: baseUnit20, priceSource: priceSource20, fixedPrice: fixedPrice20, uniswapMarket: uniswapMarket20, isUniswapReversed: isUniswapReversed20});
        if (i == 21) return TokenConfig({underlying: underlying21, symbolHash: symbolHash21, baseUnit: baseUnit21, priceSource: priceSource21, fixedPrice: fixedPrice21, uniswapMarket: uniswapMarket21, isUniswapReversed: isUniswapReversed21});
        if (i == 22) return TokenConfig({underlying: underlying22, symbolHash: symbolHash22, baseUnit: baseUnit22, priceSource: priceSource22, fixedPrice: fixedPrice22, uniswapMarket: uniswapMarket22, isUniswapReversed: isUniswapReversed22});
        if (i == 23) return TokenConfig({underlying: underlying23, symbolHash: symbolHash23, baseUnit: baseUnit23, priceSource: priceSource23, fixedPrice: fixedPrice23, uniswapMarket: uniswapMarket23, isUniswapReversed: isUniswapReversed23});
        if (i == 24) return TokenConfig({underlying: underlying24, symbolHash: symbolHash24, baseUnit: baseUnit24, priceSource: priceSource24, fixedPrice: fixedPrice24, uniswapMarket: uniswapMarket24, isUniswapReversed: isUniswapReversed24});
        if (i == 25) return TokenConfig({underlying: underlying25, symbolHash: symbolHash25, baseUnit: baseUnit25, priceSource: priceSource25, fixedPrice: fixedPrice25, uniswapMarket: uniswapMarket25, isUniswapReversed: isUniswapReversed25});
        if (i == 26) return TokenConfig({underlying: underlying26, symbolHash: symbolHash26, baseUnit: baseUnit26, priceSource: priceSource26, fixedPrice: fixedPrice26, uniswapMarket: uniswapMarket26, isUniswapReversed: isUniswapReversed26});
        if (i == 27) return TokenConfig({underlying: underlying27, symbolHash: symbolHash27, baseUnit: baseUnit27, priceSource: priceSource27, fixedPrice: fixedPrice27, uniswapMarket: uniswapMarket27, isUniswapReversed: isUniswapReversed27});
        if (i == 28) return TokenConfig({underlying: underlying28, symbolHash: symbolHash28, baseUnit: baseUnit28, priceSource: priceSource28, fixedPrice: fixedPrice28, uniswapMarket: uniswapMarket28, isUniswapReversed: isUniswapReversed28});
        if (i == 29) return TokenConfig({underlying: underlying29, symbolHash: symbolHash29, baseUnit: baseUnit29, priceSource: priceSource29, fixedPrice: fixedPrice29, uniswapMarket: uniswapMarket29, isUniswapReversed: isUniswapReversed29});
    }

    /**
     * @notice Get the config for symbol
     * @param symbol The symbol of the config to get
     * @return The config object
     */
    function getTokenConfigBySymbol(string memory symbol) public view returns (TokenConfig memory) {
        return getTokenConfigBySymbolHash(keccak256(abi.encodePacked(symbol)));
    }

    /**
     * @notice Get the config for the symbolHash
     * @param symbolHash The keccack256 of the symbol of the config to get
     * @return The config object
     */
    function getTokenConfigBySymbolHash(bytes32 symbolHash) public view returns (TokenConfig memory) {
        uint index = getSymbolHashIndex(symbolHash);
        if (index != uint(-1)) {
            return getTokenConfig(index);
        }

        revert("token config by symbol hash not found");
    }

    /**
     * @notice Get the config for an underlying asset
     * @param underlying The address of the underlying asset of the config to get
     * @return The config object
     */
    function getTokenConfigByUnderlying(address underlying) public view returns (TokenConfig memory) {
        uint index = getUnderlyingIndex(underlying);
        if (index != uint(-1)) {
            return getTokenConfig(index);
        }

        revert("token config by underlying not found");
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

/**
 * @title The Open Oracle Data Base Contract
 * @author Compound Labs, Inc.
 */
contract OpenOracleData {
    /**
     * @notice The event emitted when a source writes to its storage
     */
    //event Write(address indexed source, <Key> indexed key, string kind, uint64 timestamp, <Value> value);

    /**
     * @notice Write a bunch of signed datum to the authenticated storage mapping
     * @param message The payload containing the timestamp, and (key, value) pairs
     * @param signature The cryptographic signature of the message payload, authorizing the source to write
     * @return The keys that were written
     */
    //function put(bytes calldata message, bytes calldata signature) external returns (<Key> memory);

    /**
     * @notice Read a single key with a pre-defined type signature from an authenticated source
     * @param source The verifiable author of the data
     * @param key The selector for the value to return
     * @return The claimed Unix timestamp for the data and the encoded value (defaults to (0, 0x))
     */
    //function get(address source, <Key> key) external view returns (uint, <Value>);

    /**
     * @notice Recovers the source address which signed a message
     * @dev Comparing to a claimed address would add nothing,
     *  as the caller could simply perform the recover and claim that address.
     * @param message The data that was presumably signed
     * @param signature The fingerprint of the data + private key
     * @return The source address which signed the message, presumably
     */
    function source(bytes memory message, bytes memory signature) public view returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = abi.decode(signature, (bytes32, bytes32, uint8));
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(message)));
        return ecrecover(hash, v, r, s);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/IPriceOracle.sol";
import "./OpenOraclePriceData.sol";

/**
 * @title Ola's Open Oracle Data based price oracle.
 * @author Ola
 */
contract OpenOraclePriceOracle is IPriceOracle, Ownable {

    bytes32 constant public emptySymbolHash = keccak256("");

    OpenOraclePriceData public immutable priceData;
    address public immutable priceSigner;

    // Asset address -> matching symbol for the Open Oracle Data protocol
    mapping(address => string) public assetsSymbols;

    // Underlying -> assets decimals
    mapping(address => uint8) public assetsDecimals;

    event NewSymbolForAsset(address indexed asset, string oldSymbol, string newSymbol);

    constructor(address _priceData, address _priceSigner) {
        priceData = OpenOraclePriceData(_priceData);
        priceSigner = _priceSigner;
    }


    //// **** INTERFACE FUNCTIONS ****

    /**
     * @notice Get the price an asset
     * @param asset The asset to get the price of
     * @return The asset price mantissa (scaled by 1e18).
     *  Zero means the price is unavailable.
     */
    function getAssetPrice(address asset) external override view returns (uint) {
        return _getPriceForAssetInternal(asset);
    }

    /**
     * OLA_ADDITIONS : This function
     * @notice Get the price update timestamp for the asset
     * @param asset The asset address for price update timestamp retrieval.
     * @return Last price update timestamp for the asset
     */
    function getAssetPriceUpdateTimestamp(address asset) external override view returns (uint) {
        return _getPriceUpdateTimestampForAssetInternal(asset);
    }

    /**
      * @notice Get the underlying price of a cToken asset
      * @param cToken The cToken to get the underlying price of
      * @return The underlying asset price mantissa (scaled by 1e(36 - assetDecimals)).
      *  Zero means the price is unavailable.
      */
    function getUnderlyingPrice(address cToken) external override view returns (uint) {
        return _getPriceForAssetInternal(ICTokenForPriceOracle(cToken).underlying());
    }

    /**
     * @notice Get the price update timestamp for the cToken underlying
     * @param cToken The cToken address for price update timestamp retrieval.
     * @return Last price update timestamp for the cToken underlying asset
     */
    function getUnderlyingPriceUpdateTimestamp(address cToken) external override view returns (uint) {
        return _getPriceUpdateTimestampForAssetInternal(ICTokenForPriceOracle(cToken).underlying());
    }

    //// **** INTERFACE FUNCTIONS - END ****

    function _setAssetSymbolForUnderlying(address _underlying, string calldata _symbol) onlyOwner external {
        _setAssetSymbolsForUnderlyingInternal(_underlying, _symbol);
    }

    function _setAssetSymbolsForUnderlyings(address[] calldata _underlyings, string[] calldata _symbols) onlyOwner external {
        require(_underlyings.length == _symbols.length, "underlyings and symbols should be 1:1");

        for (uint i = 0; i < _underlyings.length; i++) {
            _setAssetSymbolsForUnderlyingInternal(_underlyings[i], _symbols[i]);
        }
    }

    function getPriceForAsset(address asset) public view returns (uint) {
        return _getPriceForAssetInternal(asset);
    }

    function hasSymbolForAsset(address asset) public view returns (bool) {
        return keccak256(abi.encodePacked(assetsSymbols[asset])) != emptySymbolHash;
    }

    function isPriceOracle() public override pure returns (bool) {
        return true;
    }

    function _setAssetSymbolsForUnderlyingInternal(address underlying, string calldata assetSymbol) internal {
        string storage existingSymbol = assetsSymbols[underlying];

        require(!hasSymbolForAsset(underlying), "Cannot reassign symbol");

        uint8 decimalsForAsset;

        if (underlying == address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)) {
            decimalsForAsset = 18;
        } else {
            decimalsForAsset = ERC20(underlying).decimals();
        }

        assetsSymbols[underlying] = assetSymbol;
        assetsDecimals[underlying] = decimalsForAsset;
        emit NewSymbolForAsset(underlying, existingSymbol, assetSymbol);
    }

    /**
      * @notice Get the underlying price of a cToken asset
      * @param asset The asset (Erc20 or native)
      * @return The asset price mantissa (scaled by 1e(36 - assetDecimals)).
      *  Zero means the price is unavailable.
      */
    function _getPriceForAssetInternal(address asset) internal view returns (uint) {
        if (hasSymbolForAsset(asset)) {
            string storage assetSymbol = assetsSymbols[asset];
            uint8 assetDecimals = assetsDecimals[asset];

            uint openPriceDataPrice = getOpenPriceDataPrice(assetSymbol);

            // Needs to be scaled to e36 and then divided by the asset's decimals
            // All OOD prices are scaled by 1e6
            return (mul(1e30, openPriceDataPrice) / (10 ** assetDecimals));
        } else {
            return 0;
        }
    }

    function _getPriceUpdateTimestampForAssetInternal(address asset) internal view returns (uint) {
        if (hasSymbolForAsset(asset)) {
            return getOpenPriceDataTimestamp(assetsSymbols[asset]);
        } else {
            return 0;
        }
    }

    function getOpenPriceDataPrice(string storage symbol) internal view returns (uint) {
        return priceData.getPrice(priceSigner, symbol);
    }

    function getOpenPriceDataTimestamp(string storage symbol) internal view returns (uint) {
        (uint64 timestamp, uint64 price) = priceData.get(priceSigner, symbol);
        return timestamp;
    }

    /// @dev Overflow proof multiplication
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) return 0;
        uint c = a * b;
        require(c / a == b, "multiplication overflow");
        return c;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

// Price oracle interface for solidity 0.7

interface ICTokenForPriceOracle {
    function underlying() external view returns (address);
}

/**
 * 0.7.6 Interface for "PriceOracle.sol"
 */
interface IPriceOracle {
    function isPriceOracle() external view returns (bool);
    function getAssetPrice(address asset) external view returns (uint);
    function getAssetPriceUpdateTimestamp(address asset) external view returns (uint);
    function getUnderlyingPrice(address cToken) external view returns (uint);
    function getUnderlyingPriceUpdateTimestamp(address cToken) external view returns (uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/IPriceOracle.sol";
import "./IWitnerPriceRouter.sol";


interface IStdReference {
    /// A structure returned whenever someone requests for standard reference data.
    struct ReferenceData {
        uint256 rate; // base/quote exchange rate, multiplied by 1e18.
        uint256 lastUpdatedBase; // UNIX epoch of the last time when base price gets updated.
        uint256 lastUpdatedQuote; // UNIX epoch of the last time when quote price gets updated.
    }

    /// Returns the price data for the given base/quote pair. Revert if not available.
    function getReferenceData(string memory _base, string memory _quote)
    external
    view
    returns (ReferenceData memory);

    /// Similar to getReferenceData, but with multiple base/quote pairs at once.
    function getReferenceDataBulk(string[] memory _bases, string[] memory _quotes)
    external
    view
    returns (ReferenceData[] memory);
}

/**
 * @title Ola's Witnet router based price oracle.
 * @author Ola
 */
contract WitnetRouterPriceOracle is IPriceOracle, Ownable {

    // The BAND protocol price source
    IWitnetPriceRouterForOracle immutable public witnetOracle;

    // Asset address -> matching ID4 for the Witnet protocol
    mapping(address => bytes32) public assetsFeedID4;

    // Underlying -> Witnet feed decimals
    mapping(address => uint8) public assetsFeedDecimals;

    // Underlying -> assets decimals
    mapping(address => uint8) public assetsDecimals;

    event NewFeedConfiguredForAsset(address indexed asset, bytes32 indexed feedID4, uint feedDecimals);

    constructor(address _witnetOracle) {
        witnetOracle = IWitnetPriceRouterForOracle(_witnetOracle);
    }

    /**
     * @notice Get the price an asset
     * @param asset The asset to get the price of
     * @return The asset price mantissa (scaled by 1e(36 - assetDecimals)).
     *  Zero means the price is unavailable.
     */
    function getAssetPrice(address asset) external override view returns (uint) {
        return _getPriceForAssetInternal(asset);
    }

    /**
     * OLA_ADDITIONS : This function
     * @notice Get the price update timestamp for the asset
     * @param asset The asset address for price update timestamp retrieval.
     * @return Last price update timestamp for the asset
     */
    function getAssetPriceUpdateTimestamp(address asset) external override view returns (uint) {
        return _getPriceUpdateTimestampForAssetInternal(asset);
    }

    /**
      * @notice Get the underlying price of a cToken asset
      * @param cToken The cToken to get the underlying price of
      * @return The underlying asset price mantissa (scaled by 1e(36 - underlyingDecimals)).
      *  Zero means the price is unavailable.
      */
    function getUnderlyingPrice(address cToken) external override view returns (uint) {
        return _getPriceForAssetInternal(ICTokenForPriceOracle(cToken).underlying());
    }

    /**
     * @notice Get the price update timestamp for the cToken underlying
     * @param cToken The cToken address for price update timestamp retrieval.
     * @return Last price update timestamp for the cToken underlying asset
     */
    function getUnderlyingPriceUpdateTimestamp(address cToken) external override view returns (uint) {
        return _getPriceUpdateTimestampForAssetInternal(ICTokenForPriceOracle(cToken).underlying());
    }

    function _supportAssetID4ForUnderlying(address _underlying, bytes32 _id4, uint8 _feedDecimals) onlyOwner external {
        _setPriceFeedForUnderlyingInternal(_underlying, _id4, _feedDecimals);
    }

    function _setAssetID4ForUnderlyings(address[] calldata _underlyings, bytes32[] calldata _id4s, uint8[] calldata _feedsDecimals) onlyOwner external {
        require(_underlyings.length == _id4s.length, "underlyings and symbols should be 1:1");
        require(_underlyings.length == _feedsDecimals.length, "underlyings and feedsDecimals should be 1:1");

        for (uint i = 0; i < _underlyings.length; i++) {
            _setPriceFeedForUnderlyingInternal(_underlyings[i], _id4s[i], _feedsDecimals[i]);
        }
    }

    function getPriceForAsset(address asset) public view returns (uint) {
        return _getPriceForAssetInternal(asset);
    }

    function hasFeedForAsset(address asset) public view returns (bool) {
        return assetsFeedID4[asset] != bytes32(0);
    }

    function isPriceOracle() public override pure returns (bool) {
        return true;
    }

    function _setPriceFeedForUnderlyingInternal(address _underlying, bytes32 _id4, uint8 _feedDecimals) internal {
        require(!hasFeedForAsset(_underlying), "Cannot reassign symbol");

        uint8 decimalsForAsset;

        if (_underlying == address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)) {
            decimalsForAsset = 18;
        } else {
            decimalsForAsset = ERC20(_underlying).decimals();
        }

        assetsDecimals[_underlying] = decimalsForAsset;
        assetsFeedID4[_underlying] = _id4;
        assetsFeedDecimals[_underlying] = _feedDecimals;
        emit NewFeedConfiguredForAsset(_underlying, _id4, _feedDecimals);
    }

    /**
      * @notice Get the underlying price of a cToken asset
      * @param asset The asset (Erc20 or native)
      * @return The asset price mantissa (scaled by 1e(36 - assetDecimals)).
      *  Zero means the price is unavailable.
      */
    function _getPriceForAssetInternal(address asset) internal view returns (uint) {
        if (hasFeedForAsset(asset)) {
            uint8 feedDecimals = assetsFeedDecimals[asset];
            uint8 assetDecimals = assetsDecimals[asset];
            bytes32 feedId4 = assetsFeedID4[asset];

            int feedPriceRaw = getWitnetPrice(feedId4);
            uint feedPrice = uint(feedPriceRaw);

            // Safety
            require(feedPriceRaw == int(feedPrice), "Price Conversion error");

            // Needs to be scaled to e36 and then divided by the asset's decimals
            if (feedDecimals == 6) {
                return (mul(1e30, feedPrice) / (10 ** assetDecimals));
            } else if (feedDecimals == 8) {
                return (mul(1e28, feedPrice) / (10 ** assetDecimals));
            } else if (feedDecimals == 18) {
                return (mul(1e18, feedPrice) / (10 ** assetDecimals));
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    }

    function _getPriceUpdateTimestampForAssetInternal(address asset) internal view returns (uint) {
        if (hasFeedForAsset(asset)) {
            return getWitnetUpdateTimestamp(assetsFeedID4[asset]);
        } else {
            return 0;
        }
    }

    function getWitnetPrice(bytes32 feedId4) internal view returns (int) {
        int value;
        (value, , ) = getWitnetRouterResponse(feedId4);
        return value;
    }

    function getWitnetUpdateTimestamp(bytes32 feedId4) internal view returns (uint) {
        uint updateTimestamp;
        (, updateTimestamp, ) = getWitnetRouterResponse(feedId4);
        return updateTimestamp;
    }

    function getWitnetRouterResponse(bytes32 feedId4) internal view returns(int256 value,uint256 timestamp, uint256 statusCode) {
        (value, timestamp, statusCode) = witnetOracle.valueFor(feedId4);
    }

    /// @dev Overflow proof multiplication
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) return 0;
        uint c = a * b;
        require(c / a == b, "multiplication overflow");
        return c;
    }
}

pragma solidity ^0.7.6;

/**
 * Witnet protocol Oracle interface
 * Based (with some changes) on the code deployed here https://blockexplorer.boba.network/address/0x93f61D0D5F623144e7C390415B70102A9Cc90bA5/contracts
 */

/**
* @dev EIP2362 Interface for pull oracles
* https://github.com/adoracles/EIPs/blob/erc-2362/EIPS/eip-2362.md
*/
interface IERC2362
{
    /**
     * @dev Exposed function pertaining to EIP standards
     * @param _id bytes32 ID of the query
     * @return int,uint,uint returns the value, timestamp, and status code of query
     */
    function valueFor(bytes32 _id) external view returns(int256,uint256,uint256);
}

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: contracts\interfaces\IWitnetPriceRouter.sol
/// @title The Witnet Price Router basic interface.
/// @dev Guides implementation of price feeds aggregation contracts.
/// @author The Witnet Foundation.
//abstract contract IWitnetPriceRouter is IERC2362 {
interface IWitnetPriceRouterForOracle is IERC2362 {

    /// Helper pure function: returns hash of the provided ERC2362-compliant currency pair caption (aka ID).
    function currencyPairId(string memory) external pure virtual returns (bytes32);

    /// Returns the ERC-165-compliant price feed contract currently serving
    /// updates on the given currency pair.
    function getPriceFeed(bytes32 _erc2362id) external view virtual returns (IERC165);

    /// Returns human-readable ERC2362-based caption of the currency pair being
    /// served by the given price feed contract address.
    /// @dev Should fail if the given price feed contract address is not currently
    /// @dev registered in the router.
    function getPriceFeedCaption(IERC165) external view virtual returns (string memory);

    /// Returns human-readable caption of the ERC2362-based currency pair identifier, if known.
    function lookupERC2362ID(bytes32 _erc2362id) external view virtual returns (string memory);

    /// Returns list of known currency pairs IDs.
    function supportedCurrencyPairs() external view virtual returns (bytes32[] memory);

    /// Returns `true` if given pair is currently being served by a compliant price feed contract.
    function supportsCurrencyPair(bytes32 _erc2362id) external view virtual returns (bool);

    /// Returns `true` if given price feed contract is currently serving updates to any known currency pair.
    function supportsPriceFeed(IERC165 _priceFeed) external view virtual returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.9 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

/**
 * @dev Contract module which acts as a timelocked controller. When set as the
 * owner of an `Ownable` smart contract, it enforces a timelock on all
 * `onlyOwner` maintenance operations. This gives time for users of the
 * controlled contract to exit before a potentially dangerous maintenance
 * operation is applied.
 *
 * By default, this contract is self administered, meaning administration tasks
 * have to go through the timelock process. The proposer (resp executor) role
 * is in charge of proposing (resp executing) operations. A common use case is
 * to position this {TimelockController} as the owner of a smart contract, with
 * a multisig or a DAO as the sole proposer.
 *
 * _Available since v3.3._
 */
contract OlaTimelock is AccessControl {

    bytes32 public constant TIMELOCK_ADMIN_ROLE = keccak256("TIMELOCK_ADMIN_ROLE");
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
    uint256 internal constant _DONE_TIMESTAMP = uint256(1);

    mapping(bytes32 => uint256) private _timestamps;
    uint256 private _minDelay;

    /**
     * @dev Emitted when a call is scheduled as part of operation `id`.
     */
    event CallScheduled(bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data, bytes32 predecessor, uint256 delay);

    /**
     * @dev Emitted when a call is performed as part of operation `id`.
     */
    event CallExecuted(bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data);

    /**
     * @dev Emitted when operation `id` is cancelled.
     */
    event Cancelled(bytes32 indexed id);

    /**
     * @dev Emitted when the minimum delay for future operations is modified.
     */
    event MinDelayChange(uint256 oldDuration, uint256 newDuration);

    /**
     * @dev Initializes the contract with a given `minDelay`.
     */
    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors) public {
        _setRoleAdmin(TIMELOCK_ADMIN_ROLE, TIMELOCK_ADMIN_ROLE);
        _setRoleAdmin(PROPOSER_ROLE, TIMELOCK_ADMIN_ROLE);
        _setRoleAdmin(EXECUTOR_ROLE, TIMELOCK_ADMIN_ROLE);

        // deployer + self administration
        _setupRole(TIMELOCK_ADMIN_ROLE, _msgSender());
        _setupRole(TIMELOCK_ADMIN_ROLE, address(this));

        // register proposers
        for (uint256 i = 0; i < proposers.length; ++i) {
            _setupRole(PROPOSER_ROLE, proposers[i]);
        }

        // register executors
        for (uint256 i = 0; i < executors.length; ++i) {
            _setupRole(EXECUTOR_ROLE, executors[i]);
        }

        _minDelay = minDelay;
        emit MinDelayChange(0, minDelay);
    }

    /**
     * @dev Modifier to make a function callable only by a certain role. In
     * addition to checking the sender's role, `address(0)` 's role is also
     * considered. Granting a role to `address(0)` is equivalent to enabling
     * this role for everyone.
     */
    modifier onlyRole(bytes32 role) {
        require(hasRole(role, _msgSender()) || hasRole(role, address(0)), "TimelockController: sender requires permission");
        _;
    }

    /**
     * @dev Contract might receive/hold ETH as part of the maintenance process.
     */
    receive() external payable {}

    /**
     * @dev Returns whether an id correspond to a registered operation. This
     * includes both Pending, Ready and Done operations.
     */
    function isOperation(bytes32 id) public view virtual returns (bool pending) {
        return getTimestamp(id) > 0;
    }

    /**
     * @dev Returns whether an operation is pending or not.
     */
    function isOperationPending(bytes32 id) public view virtual returns (bool pending) {
        return getTimestamp(id) > _DONE_TIMESTAMP;
    }

    /**
     * @dev Returns whether an operation is ready or not.
     */
    function isOperationReady(bytes32 id) public view virtual returns (bool ready) {
        uint256 timestamp = getTimestamp(id);
        // solhint-disable-next-line not-rely-on-time
        return timestamp > _DONE_TIMESTAMP && timestamp <= block.timestamp;
    }

    /**
     * @dev Returns whether an operation is done or not.
     */
    function isOperationDone(bytes32 id) public view virtual returns (bool done) {
        return getTimestamp(id) == _DONE_TIMESTAMP;
    }

    /**
     * @dev Returns the timestamp at with an operation becomes ready (0 for
     * unset operations, 1 for done operations).
     */
    function getTimestamp(bytes32 id) public view virtual returns (uint256 timestamp) {
        return _timestamps[id];
    }

    /**
     * @dev Returns the minimum delay for an operation to become valid.
     *
     * This value can be changed by executing an operation that calls `updateDelay`.
     */
    function getMinDelay() public view virtual returns (uint256 duration) {
        return _minDelay;
    }

    /**
     * @dev Returns the identifier of an operation containing a single
     * transaction.
     */
    function hashOperation(address target, uint256 value, bytes calldata data, bytes32 predecessor, bytes32 salt) public pure virtual returns (bytes32 hash) {
        return keccak256(abi.encode(target, value, data, predecessor, salt));
    }

    /**
     * @dev Returns the identifier of an operation containing a batch of
     * transactions.
     */
    function hashOperationBatch(address[] calldata targets, uint256[] calldata values, bytes[] calldata datas, bytes32 predecessor, bytes32 salt) public pure virtual returns (bytes32 hash) {
        return keccak256(abi.encode(targets, values, datas, predecessor, salt));
    }

    /**
     * @dev Schedule an operation containing a single transaction.
     *
     * Emits a {CallScheduled} event.
     *
     * Requirements:
     *
     * - the caller must have the 'proposer' role.
     */
    function schedule(address target, uint256 value, bytes calldata data, bytes32 predecessor, bytes32 salt, uint256 delay) public virtual onlyRole(PROPOSER_ROLE) {
        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        _schedule(id, delay);
        emit CallScheduled(id, 0, target, value, data, predecessor, delay);
    }

    /**
     * @dev Schedule an operation containing a batch of transactions.
     *
     * Emits one {CallScheduled} event per transaction in the batch.
     *
     * Requirements:
     *
     * - the caller must have the 'proposer' role.
     */
    function scheduleBatch(address[] calldata targets, uint256[] calldata values, bytes[] calldata datas, bytes32 predecessor, bytes32 salt, uint256 delay) public virtual onlyRole(PROPOSER_ROLE) {
        require(targets.length == values.length, "TimelockController: length mismatch");
        require(targets.length == datas.length, "TimelockController: length mismatch");

        bytes32 id = hashOperationBatch(targets, values, datas, predecessor, salt);
        _schedule(id, delay);
        for (uint256 i = 0; i < targets.length; ++i) {
            emit CallScheduled(id, i, targets[i], values[i], datas[i], predecessor, delay);
        }
    }

    /**
     * @dev Schedule an operation that is to becomes valid after a given delay.
     */
    function _schedule(bytes32 id, uint256 delay) private {
        require(!isOperation(id), "TimelockController: operation already scheduled");
        require(delay >= getMinDelay(), "TimelockController: insufficient delay");
        // solhint-disable-next-line not-rely-on-time
        _timestamps[id] = SafeMath.add(block.timestamp, delay);
    }

    /**
     * @dev Cancel an operation.
     *
     * Requirements:
     *
     * - the caller must have the 'proposer' role.
     */
    function cancel(bytes32 id) public virtual onlyRole(PROPOSER_ROLE) {
        require(isOperationPending(id), "TimelockController: operation cannot be cancelled");
        delete _timestamps[id];

        emit Cancelled(id);
    }

    /**
     * @dev Execute an (ready) operation containing a single transaction.
     *
     * Emits a {CallExecuted} event.
     *
     * Requirements:
     *
     * - the caller must have the 'executor' role.
     */
    function execute(address target, uint256 value, bytes calldata data, bytes32 predecessor, bytes32 salt) public payable virtual {
        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        _beforeCall(id, predecessor);
        _call(id, 0, target, value, data);
        _afterCall(id);
    }

    /**
     * @dev Execute an (ready) operation containing a batch of transactions.
     *
     * Emits one {CallExecuted} event per transaction in the batch.
     *
     * Requirements:
     *
     * - the caller must have the 'executor' role.
     */
    function executeBatch(address[] calldata targets, uint256[] calldata values, bytes[] calldata datas, bytes32 predecessor, bytes32 salt) public payable virtual onlyRole(EXECUTOR_ROLE) {
        require(targets.length == values.length, "TimelockController: length mismatch");
        require(targets.length == datas.length, "TimelockController: length mismatch");

        bytes32 id = hashOperationBatch(targets, values, datas, predecessor, salt);
        _beforeCall(id, predecessor);
        for (uint256 i = 0; i < targets.length; ++i) {
            _call(id, i, targets[i], values[i], datas[i]);
        }
        _afterCall(id);
    }

    /**
     * @dev Checks before execution of an operation's calls.
     */
    function _beforeCall(bytes32 id, bytes32 predecessor) private view {
        require(isOperationReady(id), "TimelockController: operation is not ready");
        require(predecessor == bytes32(0) || isOperationDone(predecessor), "TimelockController: missing dependency");
    }

    /**
     * @dev Checks after execution of an operation's calls.
     */
    function _afterCall(bytes32 id) private {
        require(isOperationReady(id), "TimelockController: operation is not ready");
        _timestamps[id] = _DONE_TIMESTAMP;
    }

    /**
     * @dev Execute an operation's call.
     *
     * Emits a {CallExecuted} event.
     */
    function _call(bytes32 id, uint256 index, address target, uint256 value, bytes calldata data) private {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success,) = target.call{value: value}(data);
        require(success, "TimelockController: underlying transaction reverted");

        emit CallExecuted(id, index, target, value, data);
    }

    /**
     * @dev Changes the minimum timelock duration for future operations.
     *
     * Emits a {MinDelayChange} event.
     *
     * Requirements:
     *
     * - the caller must be the timelock itself. This can only be achieved by scheduling and later executing
     * an operation where the timelock is the target and the data is the ABI-encoded call to this function.
     */
    function updateDelay(uint256 newDelay) external virtual {
        require(msg.sender == address(this), "TimelockController: caller must be timelock");
        emit MinDelayChange(_minDelay, newDelay);
        _minDelay = newDelay;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/EnumerableSet.sol";
import "../utils/Address.sol";
import "../utils/Context.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/Initializable.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "@gnosis.pm/safe-contracts/contracts/common/Enum.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./BaseGuard.sol";

/// @title Guardable - A contract that manages fallback calls made to this contract
contract Guardable is OwnableUpgradeable {
    event ChangedGuard(address guard);

    address public guard;

    /// @dev Set a guard that checks transactions before execution
    /// @param _guard The address of the guard to be used or the 0 address to disable the guard
    function setGuard(address _guard) external onlyOwner {
        if (_guard != address(0)) {
            require(
                BaseGuard(_guard).supportsInterface(type(IGuard).interfaceId),
                "Guard does not implement IERC165"
            );
        }
        guard = _guard;
        emit ChangedGuard(guard);
    }

    function getGuard() external view returns (address _guard) {
        return guard;
    }
}

// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

/// @title Enum - Collection of enums
/// @author Richard Meissner - <[email protected]>
contract Enum {
    enum Operation {Call, DelegateCall}
}

// SPDX-License-Identifier: LGPL-3.0-only
// pragma solidity >=0.7.0 <0.9.0;
pragma solidity >=0.6.0 <0.8.0;

import "@gnosis.pm/safe-contracts/contracts/common/Enum.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "../interfaces/IGuard.sol";

abstract contract BaseGuard is IERC165 {
    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {
        return
            interfaceId == type(IGuard).interfaceId || // 0xe6d7a83a
            interfaceId == type(IERC165).interfaceId; // 0x01ffc9a7
    }

    /// Module transactions only use the first four parameters: to, value, data, and operation.
    /// Module.sol hardcodes the remaining parameters as 0 since they are not used for module transactions.
    /// This interface is used to maintain compatibilty with Gnosis Safe transaction guards.
    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures,
        address msgSender
    ) external virtual;

    function checkAfterExecution(bytes32 txHash, bool success) external virtual;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

// pragma solidity ^0.8.0;
pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "@gnosis.pm/safe-contracts/contracts/common/Enum.sol";

interface IGuard {
    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures,
        address msgSender
    ) external;

    function checkAfterExecution(bytes32 txHash, bool success) external;
}

// SPDX-License-Identifier: LGPL-3.0-only
// Todo - Omry: update compiler after the upgrade of openzepplin to v4
// pragma solidity >=0.8.0;
pragma solidity >=0.6.0 <0.8.0;

import "@gnosis.pm/zodiac/contracts/guard/BaseGuard.sol";
import "@gnosis.pm/zodiac/contracts/factory/FactoryFriendly.sol";
import "hardhat/console.sol";
contract ScopeGuard is FactoryFriendly, BaseGuard {
    event SetTargetAllowed(address target, bool allowed);
    event SetTargetScoped(address target, bool scoped);
    event SetFallbackAllowedOnTarget(address target, bool allowed);
    event SetValueAllowedOnTarget(address target, bool allowed);
    event SetDelegateCallAllowedOnTarget(address target, bool allowed);
    event SetFunctionAllowedOnTarget(
        address target,
        bytes4 functionSig,
        bool allowed
    );
    event ScopeGuardSetup(address indexed initiator, address indexed owner);

    constructor(address _owner) {
        bytes memory initializeParams = abi.encode(_owner);
        setUp(initializeParams);
    }

    /// @dev Initialize function, will be triggered when a new proxy is deployed
    /// @param initializeParams Parameters of initialization encoded
    function setUp(bytes memory initializeParams) public override {
        __Ownable_init();
        address _owner = abi.decode(initializeParams, (address));

        transferOwnership(_owner);

        emit ScopeGuardSetup(msg.sender, _owner);
    }

    struct Target {
        bool allowed;
        bool scoped;
        bool delegateCallAllowed;
        bool fallbackAllowed;
        bool valueAllowed;
        mapping(bytes4 => bool) allowedFunctions;
    }

    mapping(address => Target) public allowedTargets;

    /// @dev Set whether or not calls can be made to an address.
    /// @notice Only callable by owner.
    /// @param target Address to be allowed/disallowed.
    /// @param allow Bool to allow (true) or disallow (false) calls to target.
    function setTargetAllowed(address target, bool allow) public onlyOwner {
        allowedTargets[target].allowed = allow;
        console.log("target %s allowed", target);
        emit SetTargetAllowed(target, allowedTargets[target].allowed);
    }

    /// @dev Set whether or not delegate calls can be made to a target.
    /// @notice Only callable by owner.
    /// @param target Address to which delegate calls should be allowed/disallowed.
    /// @param allow Bool to allow (true) or disallow (false) delegate calls to target.
    function setDelegateCallAllowedOnTarget(address target, bool allow)
        public
        onlyOwner
    {
        allowedTargets[target].delegateCallAllowed = allow;
        emit SetDelegateCallAllowedOnTarget(
            target,
            allowedTargets[target].delegateCallAllowed
        );
    }

    /// @dev Sets whether or not calls to an address should be scoped to specific function signatures.
    /// @notice Only callable by owner.
    /// @param target Address to be scoped/unscoped.
    /// @param scoped Bool to scope (true) or unscope (false) function calls on target.
    function setScoped(address target, bool scoped) public onlyOwner {
        allowedTargets[target].scoped = scoped;
        emit SetTargetScoped(target, allowedTargets[target].scoped);
    }

    /// @dev Sets whether or not a target can be sent to (incluces fallback/receive functions).
    /// @notice Only callable by owner.
    /// @param target Address to be allow/disallow sends to.
    /// @param allow Bool to allow (true) or disallow (false) sends on target.
    function setFallbackAllowedOnTarget(address target, bool allow)
        public
        onlyOwner
    {
        allowedTargets[target].fallbackAllowed = allow;
        emit SetFallbackAllowedOnTarget(
            target,
            allowedTargets[target].fallbackAllowed
        );
    }

    /// @dev Sets whether or not a target can be sent to (incluces fallback/receive functions).
    /// @notice Only callable by owner.
    /// @param target Address to be allow/disallow sends to.
    /// @param allow Bool to allow (true) or disallow (false) sends on target.
    function setValueAllowedOnTarget(address target, bool allow)
        public
        onlyOwner
    {
        allowedTargets[target].valueAllowed = allow;
        emit SetValueAllowedOnTarget(
            target,
            allowedTargets[target].valueAllowed
        );
    }

    /// @dev Sets whether or not a specific function signature should be allowed on a scoped target.
    /// @notice Only callable by owner.
    /// @param target Scoped address on which a function signature should be allowed/disallowed.
    /// @param functionSig Function signature to be allowed/disallowed.
    /// @param allow Bool to allow (true) or disallow (false) calls a function signature on target.
    function setAllowedFunction(
        address target,
        bytes4 functionSig,
        bool allow
    ) public onlyOwner {
        allowedTargets[target].allowedFunctions[functionSig] = allow;
        console.log("function allowed on target %s", target);

        emit SetFunctionAllowedOnTarget(
            target,
            functionSig,
            allowedTargets[target].allowedFunctions[functionSig]
        );
    }

    /// @dev Returns bool to indicate if an address is an allowed target.
    /// @param target Address to check.
    function isAllowedTarget(address target) public view returns (bool) {
        return (allowedTargets[target].allowed);
    }

    /// @dev Returns bool to indicate if an address is scoped.
    /// @param target Address to check.
    function isScoped(address target) public view returns (bool) {
        return (allowedTargets[target].scoped);
    }

    /// @dev Returns bool to indicate if fallback is allowed to a target.
    /// @param target Address to check.
    function isfallbackAllowed(address target) public view returns (bool) {
        return (allowedTargets[target].fallbackAllowed);
    }

    /// @dev Returns bool to indicate if ETH can be sent to a target.
    /// @param target Address to check.
    function isValueAllowed(address target) public view returns (bool) {
        return (allowedTargets[target].valueAllowed);
    }

    /// @dev Returns bool to indicate if a function signature is allowed for a target address.
    /// @param target Address to check.
    /// @param functionSig Signature to check.
    function isAllowedFunction(address target, bytes4 functionSig)
        public
        view
        returns (bool)
    {
        return (allowedTargets[target].allowedFunctions[functionSig]);
    }

    /// @dev Returns bool to indicate if delegate calls are allowed to a target address.
    /// @param target Address to check.
    function isAllowedToDelegateCall(address target)
        public
        view
        returns (bool)
    {
        return (allowedTargets[target].delegateCallAllowed);
    }

    // solhint-disallow-next-line payable-fallback
    fallback() external {
        // We don't revert on fallback to avoid issues in case of a Safe upgrade
        // E.g. The expected check method might change and then the Safe would be locked.
    }

    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256,
        uint256,
        uint256,
        address,
        // solhint-disallow-next-line no-unused-vars
        address payable,
        bytes memory,
        address
    ) external view override {
        require(
            operation != Enum.Operation.DelegateCall ||
                allowedTargets[to].delegateCallAllowed,
            "Delegate call not allowed to this address"
        );
        require(allowedTargets[to].allowed, "Target address is not allowed");
        if (value > 0) {
            require(
                allowedTargets[to].valueAllowed,
                "Cannot send ETH to this target"
            );
        }
        if (data.length >= 4) {
            
            bytes4 outBytes4 = abi.decode(data, (bytes4));
            require(
                !allowedTargets[to].scoped ||
                    // TODO-omry: switch back to commentted line after the update to oz v4.
                    // allowedTargets[to].allowedFunctions[bytes4(data)],
                    allowedTargets[to].allowedFunctions[outBytes4],
                "Target function is not allowed"
            );
        } else {
            require(data.length == 0, "Function signature too short");
            require(
                !allowedTargets[to].scoped ||
                    allowedTargets[to].fallbackAllowed,
                "Fallback not allowed for this address"
            );
        }
    }

    function checkAfterExecution(bytes32, bool) external view override {}
}

// SPDX-License-Identifier: LGPL-3.0-only

/// @title Zodiac FactoryFriendly - A contract that allows other contracts to be initializable and pass bytes as arguments to define contract state
// pragma solidity >=0.7.0 <0.9.0;
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract FactoryFriendly is OwnableUpgradeable {
    function setUp(bytes memory initializeParams) public virtual;
}

// SPDX-License-Identifier: LGPL-3.0-only

/// @title Module Interface - A contract that can pass messages to a Module Manager contract if enabled by that contract.
// pragma solidity >=0.7.0 <0.9.0;
pragma solidity >=0.6.0 <0.8.0;

import "../interfaces/IAvatar.sol";
import "../factory/FactoryFriendly.sol";
import "../guard/Guardable.sol";

abstract contract Module is FactoryFriendly, Guardable {
    /// @dev Emitted each time the avatar is set.
    event AvatarSet(address indexed previousAvatar, address indexed newAvatar);
    /// @dev Emitted each time the Target is set.
    event TargetSet(address indexed previousTarget, address indexed newTarget);

    /// @dev Address that will ultimately execute function calls.
    address public avatar;
    /// @dev Address that this module will pass transactions to.
    address public target;

    /// @dev Sets the avatar to a new avatar (`newAvatar`).
    /// @notice Can only be called by the current owner.
    function setAvatar(address _avatar) public onlyOwner {
        address previousAvatar = avatar;
        avatar = _avatar;
        emit AvatarSet(previousAvatar, _avatar);
    }

    /// @dev Sets the target to a new target (`newTarget`).
    /// @notice Can only be called by the current owner.
    function setTarget(address _target) public onlyOwner {
        address previousTarget = target;
        target = _target;
        emit TargetSet(previousTarget, _target);
    }

    /// @dev Passes a transaction to be executed by the avatar.
    /// @notice Can only be called by this contract.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction: 0 == call, 1 == delegate call.
    function exec(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) internal returns (bool success) {
        /// check if a transactioon guard is enabled.
        if (guard != address(0)) {
            IGuard(guard).checkTransaction(
                /// Transaction info used by module transactions
                to,
                value,
                data,
                operation,
                /// Zero out the redundant transaction information only used for Safe multisig transctions
                0,
                0,
                0,
                address(0),
                payable(0),
                bytes("0x"),
                address(0)
            );
        }
        success = IAvatar(target).execTransactionFromModule(
            to,
            value,
            data,
            operation
        );
        if (guard != address(0)) {
            IGuard(guard).checkAfterExecution(bytes32("0x"), success);
        }
        return success;
    }

    /// @dev Passes a transaction to be executed by the target and returns data.
    /// @notice Can only be called by this contract.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction: 0 == call, 1 == delegate call.
    function execAndReturnData(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) internal returns (bool success, bytes memory returnData) {
        /// check if a transactioon guard is enabled.
        if (guard != address(0)) {
            IGuard(guard).checkTransaction(
                /// Transaction info used by module transactions
                to,
                value,
                data,
                operation,
                /// Zero out the redundant transaction information only used for Safe multisig transctions
                0,
                0,
                0,
                address(0),
                payable(0),
                bytes("0x"),
                address(0)
            );
        }
        (success, returnData) = IAvatar(target)
            .execTransactionFromModuleReturnData(to, value, data, operation);
        if (guard != address(0)) {
            IGuard(guard).checkAfterExecution(bytes32("0x"), success);
        }
        return (success, returnData);
    }
}

// SPDX-License-Identifier: LGPL-3.0-only

/// @title Zodiac Avatar - A contract that manages modules that can execute transactions via this contract.
// pragma solidity >=0.7.0 <0.9.0;
pragma solidity >=0.6.0 <0.8.0;

import "@gnosis.pm/safe-contracts/contracts/common/Enum.sol";

interface IAvatar {
    /// @dev Enables a module on the avatar.
    /// @notice Can only be called by the avatar.
    /// @notice Modules should be stored as a linked list.
    /// @notice Must emit EnabledModule(address module) if successful.
    /// @param module Module to be enabled.
    function enableModule(address module) external;

    /// @dev Disables a module on the avatar.
    /// @notice Can only be called by the avatar.
    /// @notice Must emit DisabledModule(address module) if successful.
    /// @param prevModule Address that pointed to the module to be removed in the linked list
    /// @param module Module to be removed.
    function disableModule(address prevModule, address module) external;

    /// @dev Allows a Module to execute a transaction.
    /// @notice Can only be called by an enabled module.
    /// @notice Must emit ExecutionFromModuleSuccess(address module) if successful.
    /// @notice Must emit ExecutionFromModuleFailure(address module) if unsuccessful.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction: 0 == call, 1 == delegate call.
    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) external returns (bool success);

    /// @dev Allows a Module to execute a transaction and return data
    /// @notice Can only be called by an enabled module.
    /// @notice Must emit ExecutionFromModuleSuccess(address module) if successful.
    /// @notice Must emit ExecutionFromModuleFailure(address module) if unsuccessful.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction: 0 == call, 1 == delegate call.
    function execTransactionFromModuleReturnData(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) external returns (bool success, bytes memory returnData);

    /// @dev Returns if an module is enabled
    /// @return True if the module is enabled
    function isModuleEnabled(address module) external view returns (bool);

    /// @dev Returns array of modules.
    /// @param start Start of the page.
    /// @param pageSize Maximum number of modules that should be returned.
    /// @return array Array of modules.
    /// @return next Start of the next page.
    function getModulesPaginated(address start, uint256 pageSize)
        external
        view
        returns (address[] memory array, address next);
}

// SPDX-License-Identifier: LGPL-3.0-only

/// @title Modifier Interface - A contract that sits between a Module and an Avatar and enforce some additional logic.
// pragma solidity >=0.7.0 <0.9.0;
pragma solidity >=0.6.0 <0.8.0;

import "../interfaces/IAvatar.sol";
import "./Module.sol";

abstract contract Modifier is Module {
    event EnabledModule(address module);
    event DisabledModule(address module);

    address internal constant SENTINEL_MODULES = address(0x1);

    // Mapping of modules
    mapping(address => address) internal modules;

    /*
    --------------------------------------------------
    You must override at least one of following two virtual functions,
    execTransactionFromModule() and execTransactionFromModuleReturnData().
    */

    /// @dev Passes a transaction to the modifier.
    /// @param to Destination address of module transaction
    /// @param value Ether value of module transaction
    /// @param data Data payload of module transaction
    /// @param operation Operation type of module transaction
    /// @notice Can only be called by enabled modules
    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    ) public virtual moduleOnly returns (bool success) {}

    /// @dev Passes a transaction to the modifier, expects return data.
    /// @param to Destination address of module transaction
    /// @param value Ether value of module transaction
    /// @param data Data payload of module transaction
    /// @param operation Operation type of module transaction
    /// @notice Can only be called by enabled modules
    function execTransactionFromModuleReturnData(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    )
        public
        virtual
        moduleOnly
        returns (bool success, bytes memory returnData)
    {}

    /*
    --------------------------------------------------
    */

    modifier moduleOnly() {
        require(modules[msg.sender] != address(0), "Module not authorized");
        _;
    }

    /// @dev Disables a module on the modifier
    /// @param prevModule Module that pointed to the module to be removed in the linked list
    /// @param module Module to be removed
    /// @notice This can only be called by the owner
    function disableModule(address prevModule, address module)
        public
        onlyOwner
    {
        require(
            module != address(0) && module != SENTINEL_MODULES,
            "Invalid module"
        );
        require(modules[prevModule] == module, "Module already disabled");
        modules[prevModule] = modules[module];
        modules[module] = address(0);
        emit DisabledModule(module);
    }

    /// @dev Enables a module that can add transactions to the queue
    /// @param module Address of the module to be enabled
    /// @notice This can only be called by the owner
    function enableModule(address module) public onlyOwner {
        require(
            module != address(0) && module != SENTINEL_MODULES,
            "Invalid module"
        );
        require(modules[module] == address(0), "Module already enabled");
        modules[module] = modules[SENTINEL_MODULES];
        modules[SENTINEL_MODULES] = module;
        emit EnabledModule(module);
    }

    /// @dev Returns if an module is enabled
    /// @return True if the module is enabled
    function isModuleEnabled(address _module) public view returns (bool) {
        return SENTINEL_MODULES != _module && modules[_module] != address(0);
    }

    /// @dev Returns array of modules.
    /// @param start Start of the page.
    /// @param pageSize Maximum number of modules that should be returned.
    /// @return array Array of modules.
    /// @return next Start of the next page.
    function getModulesPaginated(address start, uint256 pageSize)
        external
        view
        returns (address[] memory array, address next)
    {
        // Init array with max page size
        array = new address[](pageSize);

        // Populate return array
        uint256 moduleCount = 0;
        address currentModule = modules[start];
        while (
            currentModule != address(0x0) &&
            currentModule != SENTINEL_MODULES &&
            moduleCount < pageSize
        ) {
            array[moduleCount] = currentModule;
            currentModule = modules[currentModule];
            moduleCount++;
        }
        next = currentModule;
        // Set correct size of returned array
        // solhint-disable-next-line no-inline-assembly
        assembly {
            mstore(array, moduleCount)
        }
    }
}

// SPDX-License-Identifier: LGPL-3.0-only
// Todo - Omry: update compiler after the upgrade of openzepplin to v4
// pragma solidity >=0.8.0;
pragma solidity >=0.6.0 <0.8.0;


import "@gnosis.pm/zodiac/contracts/core/Modifier.sol";
/**
 * @dev Contract module which acts as a timelocked controller. When set as the
 * owner of an `Ownable` smart contract, it enforces a timelock on all
 * `onlyOwner` maintenance operations. This gives time for users of the
 * controlled contract to exit before a potentially dangerous maintenance
 * operation is applied.
 *
 * By default, this contract is self administered, meaning administration tasks
 * have to go through the timelock process. The proposer (resp executor) role
 * is in charge of proposing (resp executing) operations. A common use case is
 * to position this {TimelockController} as the owner of a smart contract, with
 * a multisig or a DAO as the sole proposer.
 *
 * _Available since v3.3._
 */
contract OlaModule is Modifier {

    event OlaModuleSetup(
        address indexed initiator,
        address indexed owner,
        address indexed avatar,
        address target
    );

     /// @param _owner Address of the owner
    /// @param _avatar Address of the avatar (e.g. a Gnosis Safe)
    /// @param _target Address of the contract that will call exec function
     /// @notice There need to be at least 60 seconds between end of cooldown and expiration
    constructor(
        address _owner,
        address _avatar,
        address _target
    ) {
        bytes memory initParams =
            abi.encode(_owner, _avatar, _target);
        setUp(initParams);
    }

    function setUp(bytes memory initParams) public override {
        (
            address _owner,
            address _avatar,
            address _target
        ) =
            abi.decode(
                initParams,
                (address, address, address)
            );
        __Ownable_init();
        require(_avatar != address(0), "Avatar can not be zero address");
        require(_target != address(0), "Target can not be zero address");


        avatar = _avatar;
        target = _target;


        transferOwnership(_owner);
        setupModules();

        emit OlaModuleSetup(msg.sender, _owner, _avatar, _target);
    }

    function setupModules() internal {
        require(
            modules[SENTINEL_MODULES] == address(0),
            "setUpModules has already been called"
        );
        modules[SENTINEL_MODULES] = SENTINEL_MODULES;
    }

 function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    ) public override moduleOnly returns (bool success){
        require(exec(to, value, data, operation), "Module transaction failed");
    }
}

// SPDX-License-Identifier: LGPL-3.0-only
// Todo - Omry: update compiler after the upgrade of openzepplin to v4
// pragma solidity >=0.8.0;
pragma solidity >=0.6.0 <0.8.0;


import "@gnosis.pm/zodiac/contracts/core/Modifier.sol";
contract Delay is Modifier {
    event DelaySetup(
        address indexed initiator,
        address indexed owner,
        address indexed avatar,
        address target
    );
    event TransactionAdded(
        uint256 indexed queueNonce,
        bytes32 indexed txHash,
        address to,
        uint256 value,
        bytes data,
        Enum.Operation operation
    );  

    uint256 public txCooldown;
    uint256 public txExpiration;
    uint256 public txNonce;
    uint256 public queueNonce;
    // Mapping of queue nonce to transaction hash.
    mapping(uint256 => bytes32) public txHash;
    // Mapping of queue nonce to creation timestamp.
    mapping(uint256 => uint256) public txCreatedAt;

    /// @param _owner Address of the owner
    /// @param _avatar Address of the avatar (e.g. a Gnosis Safe)
    /// @param _target Address of the contract that will call exec function
    /// @param _cooldown Cooldown in seconds that should be required after a transaction is proposed
    /// @param _expiration Duration that a proposed transaction is valid for after the cooldown, in seconds (or 0 if valid forever)
    /// @notice There need to be at least 60 seconds between end of cooldown and expiration
    constructor(
        address _owner,
        address _avatar,
        address _target,
        uint256 _cooldown,
        uint256 _expiration
    ) {
        bytes memory initParams =
            abi.encode(_owner, _avatar, _target, _cooldown, _expiration);
        setUp(initParams);
    }

    function setUp(bytes memory initParams) public override {
        (
            address _owner,
            address _avatar,
            address _target,
            uint256 _cooldown,
            uint256 _expiration
        ) =
            abi.decode(
                initParams,
                (address, address, address, uint256, uint256)
            );
        __Ownable_init();
        require(_avatar != address(0), "Avatar can not be zero address");
        require(_target != address(0), "Target can not be zero address");
        require(
            _expiration == 0 || _expiration >= 60,
            "Expiratition must be 0 or at least 60 seconds"
        );

        avatar = _avatar;
        target = _target;
        txExpiration = _expiration;
        txCooldown = _cooldown;

        transferOwnership(_owner);
        setupModules();

        emit DelaySetup(msg.sender, _owner, _avatar, _target);
    }

    function setupModules() internal {
        require(
            modules[SENTINEL_MODULES] == address(0),
            "setUpModules has already been called"
        );
        modules[SENTINEL_MODULES] = SENTINEL_MODULES;
    }

    /// @dev Sets the cooldown before a transaction can be executed.
    /// @param cooldown Cooldown in seconds that should be required before the transaction can be executed
    /// @notice This can only be called by the owner
    function setTxCooldown(uint256 cooldown) public onlyOwner {
        txCooldown = cooldown;
    }

    /// @dev Sets the duration for which a transaction is valid.
    /// @param expiration Duration that a transaction is valid in seconds (or 0 if valid forever) after the cooldown
    /// @notice There need to be at least 60 seconds between end of cooldown and expiration
    /// @notice This can only be called by the owner
    function setTxExpiration(uint256 expiration) public onlyOwner {
        require(
            expiration == 0 || expiration >= 60,
            "Expiratition must be 0 or at least 60 seconds"
        );
        txExpiration = expiration;
    }

    /// @dev Sets transaction nonce. Used to invalidate or skip transactions in queue.
    /// @param _nonce New transaction nonce
    /// @notice This can only be called by the owner
    function setTxNonce(uint256 _nonce) public onlyOwner {
        require(
            _nonce > txNonce,
            "New nonce must be higher than current txNonce"
        );
        require(_nonce <= queueNonce, "Cannot be higher than queueNonce");
        txNonce = _nonce;
    }

    /// @dev Adds a transaction to the queue (same as avatar interface so that this can be placed between other modules and the avatar).
    /// @param to Destination address of module transaction
    /// @param value Ether value of module transaction
    /// @param data Data payload of module transaction
    /// @param operation Operation type of module transaction
    /// @notice Can only be called by enabled modules
    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    ) public override moduleOnly returns (bool success) {
        txHash[queueNonce] = getTransactionHash(to, value, data, operation);
        txCreatedAt[queueNonce] = block.timestamp;
        emit TransactionAdded(
            queueNonce,
            txHash[queueNonce],
            to,
            value,
            data,
            operation
        );
        queueNonce++;
        success = true;
    }

    /// @dev Executes the next transaction only if the cooldown has passed and the transaction has not expired
    /// @param to Destination address of module transaction
    /// @param value Ether value of module transaction
    /// @param data Data payload of module transaction
    /// @param operation Operation type of module transaction
    /// @notice The txIndex used by this function is always 0
    function executeNextTx(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    ) public {
        require(txNonce < queueNonce, "Transaction queue is empty");
        require(
            block.timestamp - txCreatedAt[txNonce] >= txCooldown,
            "Transaction is still in cooldown"
        );
        if (txExpiration != 0) {
            require(
                txCreatedAt[txNonce] + txCooldown + txExpiration >=
                    block.timestamp,
                "Transaction expired"
            );
        }
        require(
            txHash[txNonce] == getTransactionHash(to, value, data, operation),
            "Transaction hashes do not match"
        );
        txNonce++;

        require(exec(to, value, data, operation), "Module transaction failed");
    }

    function skipExpired() public {
        while (
            txExpiration != 0 &&
            txCreatedAt[txNonce] + txCooldown + txExpiration <
            block.timestamp &&
            txNonce < queueNonce
        ) {
            txNonce++;
        }
    }

    function getTransactionHash(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(to, value, data, operation));
    }

    function getTxHash(uint256 _nonce) public view returns (bytes32) {
        return (txHash[_nonce]);
    }

    function getTxCreatedAt(uint256 _nonce) public view returns (uint256) {
        return (txCreatedAt[_nonce]);
    }
}

pragma solidity ^0.7.6;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./ReentrancyGuard.sol";

interface IGaugeProxy {
    function gauges(address token) external view returns (address gauge);

    function tokens() external view returns (address[] memory);

    function poke(address _owner) external;
}

interface IRainstrategy {
    function vote(address[] calldata _tokenVote, uint256[] calldata _weights)
        external;
}

/**
    A contract to vote on inSpirit gauges on behalf of votinSPIRIT holders
*/
contract inSpiritVoter is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public owner;
    IGaugeProxy public gaugeProxy;
    IRainstrategy public immutable rainStrategy;
    IERC20 public immutable votinSpirit;

    uint256 public constant minDepositDuration = (7 days * 3) / 2;

    mapping(address => uint256) public depositedVotingSpirit;

    uint256 public totalWeight;
    mapping(address => uint256) public weights; // token => weight
    mapping(address => mapping(address => uint256)) public votes; // msg.sender => votes
    mapping(address => address[]) public tokenVote; // msg.sender => token
    mapping(address => uint256) public usedWeights; // msg.sender => total voting weight of user

    mapping(address => uint256) public depositingTime; // msg.sender => depositing timestamp

    modifier onlyOwner() {
        require(msg.sender == owner, "!Owner");
        _;
    }

    constructor(
        address _owner,
        address _gaugeProxy,
        address _votinSpirit,
        address _rainStrategy
    ) {
        owner = _owner;
        gaugeProxy = IGaugeProxy(_gaugeProxy);
        rainStrategy = IRainstrategy(_rainStrategy);
        votinSpirit = IERC20(_votinSpirit);
    }

    function transferOwnership(address newOwner)
        external
        onlyOwner
        nonReentrant
    {
        address oldOwner = owner;
        owner = newOwner;
        _pokeVoter(oldOwner);
        _pokeVoter(newOwner);
    }

    function setGaugeProxy(address newGaugeProxy)
        external
        onlyOwner
        nonReentrant
    {
        gaugeProxy = IGaugeProxy(newGaugeProxy);
    }

    /**
     * @notice Tokens are expected to be sorted by their address (lower address first)
     */
    function depositAndVote(
        uint256 amount,
        address[] calldata _tokenVote,
        uint256[] calldata _weights
    ) external nonReentrant {
        _deposit(amount);
        _voteVerifyLengths(msg.sender, _tokenVote, _weights);
    }

    function deposit(uint256 amount) external nonReentrant {
        _deposit(amount);
    }

    function _deposit(uint256 amount) internal {
        votinSpirit.safeTransferFrom(msg.sender, address(this), amount);
        uint256 depositedAmount = depositedVotingSpirit[msg.sender];
        depositedVotingSpirit[msg.sender] += amount;
        depositingTime[msg.sender] = block.timestamp;

        if (depositedAmount > 0 && amount > 0) {
            _pokeVoter(msg.sender);
        }
    }

    function verifyCanWithdraw(address voter) public view {
        require(
            depositingTime[voter] + minDepositDuration <= block.timestamp,
            "Not enough depositing duration"
        );
    }

    function withdrawAll() external nonReentrant {
        _withdraw(0, true);
    }

    function withdraw(uint256 amount) external nonReentrant {
        _withdraw(amount, false);
    }

    function _withdraw(uint256 amount, bool all) internal {
        verifyCanWithdraw(msg.sender);

        uint256 userAmount = depositedVotingSpirit[msg.sender];
        if (all) {
            amount = userAmount;
        } else {
            require(amount <= userAmount, "Not enough deposited tokens");
        }

        uint256 withdrawPart = amount.mul(1e18).div(userAmount);
        _reset(msg.sender, withdrawPart);

        depositedVotingSpirit[msg.sender] -= amount;
        votinSpirit.safeTransfer(msg.sender, amount);
    }

    // Reset votes to 0 if part is 1e18 (100%)
    // Reset votes to part percentage if part is > 0.
    function _reset(address _owner, uint256 part) internal {
        require(part <= 1e18, "Part is percentage (1e18)");

        address[] storage _tokenVote = tokenVote[_owner];
        uint256 _tokenVoteCnt = _tokenVote.length;
        uint256 _resettingVotes = 0;

        for (uint256 i = 0; i < _tokenVoteCnt; i++) {
            address _token = _tokenVote[i];
            uint256 _votes = votes[_owner][_token];
            uint256 _partVotes = _votes.mul(part).div(1e18);

            if (_votes > 0) {
                totalWeight = totalWeight.sub(_partVotes);
                weights[_token] = weights[_token].sub(_partVotes);

                votes[_owner][_token] = _votes.sub(_partVotes);
                _resettingVotes += _partVotes;
            }
        }

        usedWeights[_owner] -= _resettingVotes;

        if (1e18 == part) {
            delete tokenVote[_owner];
        }
    }

    function isGaugeExists(address token) public view returns (bool isExists) {
        return address(0x0) != gaugeProxy.gauges(token);
    }

    /**
     * @notice This function should be run after resetting user's votes
     * because it's running under the assumption that totalWeight doesn't include
     * the user's weight (Relevant only for the owner).
     */
    function getWeight(address user) internal view returns (uint256 weight) {
        if (owner != user) {
            return depositedVotingSpirit[user];
        }

        require(0 == usedWeights[user], "Faulty weights state");

        uint256 totalVotinSpirit = votinSpirit.totalSupply();
        return totalVotinSpirit.sub(totalWeight);
    }

    function pokeVoter(address voter) external nonReentrant {
        _pokeVoter(voter);
    }

    function _pokeVoter(address voter) internal {
        address[] memory voterTokensVoted = tokenVote[voter];
        uint256 _tokenCnt = voterTokensVoted.length;
        uint256[] memory voterUsedWeights = new uint256[](_tokenCnt);

        for (uint256 index = 0; index < _tokenCnt; index++) {
            address token = voterTokensVoted[index];
            voterUsedWeights[index] = votes[voter][token];
        }
        _vote(voter, voterTokensVoted, voterUsedWeights);
    }

    // returns the relative weight of the voter (0.5 * 1e18 means 50%)
    function getVoterWeightShare(address voter)
        external
        view
        returns (uint256 share)
    {
        if (0 == totalWeight) {
            require(0 == usedWeights[voter], "Total weight is faulty");
            return 0;
        }

        uint256 totalVotinSpirit = votinSpirit.totalSupply();
        return usedWeights[voter].mul(1e18).div(totalVotinSpirit);
    }

    function _voteVerifyLengths(
        address voter,
        address[] calldata _tokenVote,
        uint256[] calldata _weights
    ) internal {
        require(_tokenVote.length == _weights.length, "Lengths don't match");
        require(0 < _tokenVote.length, "Can't be empty"); // TODO: Think about it

        _vote(voter, _tokenVote, _weights);
    }

    /**
     * @notice Tokens are expected to be sorted by their address (lower address first)
     */
    function _vote(
        address voter,
        address[] memory _tokenVote,
        uint256[] memory _weights
    ) internal {
        _reset(voter, 1e18);
        uint256 _tokenCnt = _tokenVote.length;
        uint256 _weight = getWeight(voter);
        uint256 _totalVoteWeight = 0;
        uint256 _usedWeight = 0;

        for (uint256 i = 0; i < _tokenCnt; i++) {
            _totalVoteWeight = _totalVoteWeight.add(_weights[i]);
        }

        for (uint256 i = 0; i < _tokenCnt; i++) {
            address _token = _tokenVote[i];
            require(
                i == 0 || _token > _tokenVote[i - 1],
                "Tokens list aren't sorted"
            );
            uint256 _tokenWeight = _weights[i].mul(_weight).div(
                _totalVoteWeight
            );

            if (isGaugeExists(_token)) {
                _usedWeight = _usedWeight.add(_tokenWeight);
                totalWeight = totalWeight.add(_tokenWeight);
                weights[_token] = weights[_token].add(_tokenWeight);
                tokenVote[voter].push(_token);
                votes[voter][_token] = _tokenWeight;
            }
        }

        usedWeights[voter] = _usedWeight;
    }

    /**
     * @notice Tokens are expected to be sorted by their address (lower address first)
     */
    function vote(address[] calldata _tokenVote, uint256[] calldata _weights)
        external
        nonReentrant
    {
        _voteVerifyLengths(msg.sender, _tokenVote, _weights);
    }

    function applyVotes() external nonReentrant {
        _pokeVoter(owner);

        address[] memory tokensToVote = gaugeProxy.tokens();
        uint256[] memory weightsToVote = new uint256[](tokensToVote.length);
        for (uint256 index = 0; index < tokensToVote.length; index++) {
            weightsToVote[index] = weights[tokensToVote[index]];
        }
        rainStrategy.vote(tokensToVote, weightsToVote);
    }

    function pokeAll() external nonReentrant {
        gaugeProxy.poke(address(rainStrategy));
    }
}

pragma solidity >=0.6.7;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

pragma solidity ^0.7.6;

import "../../Tools/Helpers/TransferHelper.sol";

interface IERC20ForLiquidator {
    function balanceOf(address owner) external view returns (uint);
}

interface IWETHForLiquidator {
    function withdraw(uint amount) external;
    function deposit() external payable;
}

interface CEthInterfaceForLiquidator {
    function liquidateBorrow(address borrower, address cTokenCollateral) external payable; // CToken instead of address
}

interface CErc20InterfaceForLiquidator {
    function liquidateBorrow(address borrower, uint amountToRepay, address cTokenCollateral) external returns (uint); // CTokenInterface instead of address
}

interface CTokenInterfaceForLiquidator {
    function redeem(uint redeemTokens) external returns (uint);
    function underlying() external view returns (address);
    function accrueInterest() external returns (uint);
    function borrowBalanceStored(address account) external view returns (uint);
    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);
    function getCash() external view returns (uint);
    function comptroller() external view returns (address); // DAVID : is this correct syntax ?
    function exchangeRateStored() external returns (uint);
}

contract LiquidatorBase {
    address public constant NATIVE = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    uint public constant fixedCloseFactor = 0.5e18;
    uint public constant expScale = 1e18;

    // TODO : CRITICAL : Add address
    address public immutable W_NATIVE; // changes per chain WETH/WBNB/etc.

    constructor(address wNative_) {
        W_NATIVE = wNative_;
    }

    /**
     * Liquidates the position after ensuring self balance is sufficient
     */
    function liquidateWithSafeRepayAmountAndRedeem(
        address cTokenBorrow,
        address borrower,
        uint repayAmount,
        address cTokenCollateral
    ) internal returns (uint cTokenCollateralAmountSeized) {
        uint safeRepayAmount = getSafeRepayAmount(cTokenBorrow, cTokenCollateral, borrower, repayAmount);

        cTokenCollateralAmountSeized = liquidatePosition(cTokenBorrow, borrower, safeRepayAmount, cTokenCollateral, true);

        // TODO : make sure that redeeming cETH ends up in WETH due to receive() -- ??
        require(CTokenInterfaceForLiquidator(cTokenCollateral).redeem(cTokenCollateralAmountSeized) == 0, "redeem fail");
    }

    /**
     * Liquidates the position after ensuring self balance is sufficient
     */
    function liquidateWithSafeRepayAmount(
        address cTokenBorrow,
        address borrower,
        uint repayAmount,
        address cTokenCollateral
    ) internal returns (uint cTokenCollateralAmountSeized) {
        uint safeRepayAmount = getSafeRepayAmount(cTokenBorrow, cTokenCollateral, borrower, repayAmount);

        cTokenCollateralAmountSeized = liquidatePosition(cTokenBorrow, borrower, safeRepayAmount, cTokenCollateral, true);
    }

    /**
     * Liquidates the position after ensuring self balance is sufficient
     */
    function liquidatePositionAndRedeemInternal(
        address cTokenBorrow,
        address borrower,
        uint repayAmount,
        address cTokenCollateral
    ) internal returns (uint cTokenCollateralAmountSeized) {
        cTokenCollateralAmountSeized = liquidatePosition(cTokenBorrow, borrower, repayAmount, cTokenCollateral, true);

        // TODO : make sure that redeeming cETH ends up in WETH due to receive() -- ??
        require(CTokenInterfaceForLiquidator(cTokenCollateral).redeem(cTokenCollateralAmountSeized) == 0, "redeem fail");
    }

    /**
     * Does basic sanity and liquidates the position.
     * @param checkBalance Used to account for minor logical-flow inconsistencies regarding wNative
     */
    function liquidatePosition(
        address cTokenBorrow, 
        address borrower, 
        uint repayAmount, 
        address cTokenCollateral, 
        bool checkBalance
    ) internal returns (uint cTokenCollateralAmountSeized) {
        address underlyingBorrow = CTokenInterfaceForLiquidator(cTokenBorrow).underlying();

        if (checkBalance) {
            // Safety -- Ensure contract has enough balance in borrowed asset
            uint borrowedAssetSelfBalance = _safeSelfBalanceOfUnderlying(underlyingBorrow);
            require(borrowedAssetSelfBalance >= repayAmount, "not enough to repay");
        }

        cTokenCollateralAmountSeized = liquidatePositionInternal(cTokenBorrow, underlyingBorrow, borrower, repayAmount, cTokenCollateral);
    }

    function liquidatePositionInternal(
        address cTokenBorrow,
        address underlyingBorrow,
        address borrower,
        uint amountToRepay,
        address cTokenCollateral
    )
    private
    returns (uint cTokenCollateralAmountSeized)
    {
        if (underlyingBorrow == NATIVE) {
            cTokenCollateralAmountSeized = _liquidatePositionEth(cTokenBorrow, borrower, amountToRepay, cTokenCollateral);
        } else {
            cTokenCollateralAmountSeized = _liquidatePositionErc(underlyingBorrow, cTokenBorrow, borrower, amountToRepay, cTokenCollateral);
        }
    }

    // **** Liquidation functions ****
    // **** Note : Both functions should work exactly the same (same sanity and logic, just erc20 vs native) ****

    function _liquidatePositionEth(
        address cTokenBorrow,
        address borrower,
        uint amountToRepay,
        address cTokenCollateral
    )
    internal
    returns (uint cTokenCollateralAmountSeized)
    {
        uint balanceCTokenCollateralBefore = IERC20ForLiquidator(cTokenCollateral).balanceOf(address(this));

        // reverts if failure
        CEthInterfaceForLiquidator(cTokenBorrow).liquidateBorrow{value : amountToRepay}(borrower, cTokenCollateral);

        uint balanceCTokenCollateralAfter = IERC20ForLiquidator(cTokenCollateral).balanceOf(address(this));
        require(balanceCTokenCollateralAfter > balanceCTokenCollateralBefore, "nothing seized native");
        uint cTokenGained = balanceCTokenCollateralAfter - balanceCTokenCollateralBefore;


        cTokenCollateralAmountSeized = cTokenGained;
    }

    function _liquidatePositionErc(
        address underlyingBorrow,
        address cTokenBorrow,
        address borrower,
        uint amountToRepay,
        address cTokenCollateral
    )
    internal
    returns (uint cTokenCollateralAmountSeized)
    {
        uint balanceCTokenCollateralBefore = IERC20ForLiquidator(cTokenCollateral).balanceOf(address(this));

        // Setting to 0 before setting to wanted amount
        TransferHelper.safeApprove(underlyingBorrow, cTokenBorrow, 0);
        TransferHelper.safeApprove(underlyingBorrow, cTokenBorrow, amountToRepay);

        require(CErc20InterfaceForLiquidator(cTokenBorrow).liquidateBorrow(borrower, amountToRepay, cTokenCollateral) == 0, "liquidation fail");

        uint balanceCTokenCollateralAfter = IERC20ForLiquidator(cTokenCollateral).balanceOf(address(this));
        require(balanceCTokenCollateralAfter > balanceCTokenCollateralBefore, "nothing seized erc");
        cTokenCollateralAmountSeized = balanceCTokenCollateralAfter - balanceCTokenCollateralBefore;
    }

    // **** Calculations utils ****

    function getSafeRepayAmount(address cTokenBorrow, address cTokenCollateral, address borrower, uint repayAmount) internal returns (uint) {
        require(CTokenInterfaceForLiquidator(cTokenBorrow).accrueInterest() == 0, "borrow accrue");

        // TODO : Using 'cToken.borrowBalanceCurrent' will retrieve the 'borrowBalanceStored' after accruing interest
        if (cTokenBorrow != cTokenCollateral) {
            require(CTokenInterfaceForLiquidator(cTokenCollateral).accrueInterest() == 0, "collateral accrue");
        }

        uint totalBorrow = CTokenInterfaceForLiquidator(cTokenBorrow).borrowBalanceStored(borrower);

        // TODO : CRITICAL : SafeMath
        uint maxClose = (fixedCloseFactor * totalBorrow) / expScale;

        // amountOut desired from swap
        if (repayAmount == 0) {
            // Removing a bit of dust to avoid rounding errors
//            repayAmount = maxClose - 1e1;
            repayAmount = maxClose;
        } else {
            require(repayAmount <= maxClose, "repayAmount too big");
        }

        return repayAmount;
    }

    function _safeSelfBalanceOfUnderlying(address token) internal returns (uint balance) {
        if (token == NATIVE) {
            // NOTE : self balance caused problems in the past
            balance = address(this).balance;
        } else {
            balance = IERC20ForLiquidator(token).balanceOf(address(this));
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

pragma solidity ^0.7.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./LiquidatorBase.sol";

contract SingleOwnerLiquidator is Ownable, LiquidatorBase {

    constructor(address wrappedNative) LiquidatorBase(wrappedNative) {
    }

    function liquidatePositionAndKeep(
        address cTokenBorrow,
        address borrower,
        uint repayAmount,
        address cTokenCollateral
    ) external onlyOwner returns (uint cTokenCollateralAmountSeized) {
        require(repayAmount > 0, "RepayAmount zero");
        cTokenCollateralAmountSeized = liquidateWithSafeRepayAmount(cTokenBorrow, borrower, repayAmount, cTokenCollateral);
    }

    function liquidatePositionAndRedeem(
        address cTokenBorrow,
        address borrower,
        uint repayAmount,
        address cTokenCollateral
    ) external onlyOwner returns (uint cTokenCollateralAmountSeized) {
        require(repayAmount > 0, "RepayAmount zero");
        cTokenCollateralAmountSeized = liquidatePositionAndRedeemInternal(cTokenBorrow, borrower, repayAmount, cTokenCollateral);
    }

    /**
     * @notice Sends all balance to owner
     * @param tokens The addresses of the ERC-20 tokens to sweep
     */
    function sweepTokens(ERC20[] calldata tokens) onlyOwner external {
        uint length = tokens.length;
        for (uint i =0; i < length; i++) {
            sweepTokenInternal(tokens[i]);
        }
    }

    /**
     * @notice Sends all balance to owner
     * @param token The address of the ERC-20 token to sweep
     */
    function sweepToken(ERC20 token) onlyOwner external {
        sweepTokenInternal(token);
    }

    function sweepNative(uint amount) onlyOwner external {
        uint toTransfer = amount;

        if (toTransfer == 0) {
            toTransfer = address(this).balance;
        }

        // sender should be limited !
        msg.sender.transfer(toTransfer);
    }

    function sweepTokenInternal(ERC20 token) internal {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(owner(), balance);
    }

    /**
     * Allows receiving of native
     */
    receive() external payable virtual {
    }

    // TODO : CRITICAL : Add general caller function
}

pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./LiquidatorBase.sol";
import "./V2PairReader.sol";
import "./SingleOwnerLiquidator.sol";

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

// DAVID : why not IComptrollerForLiquidator ? 
interface ComptrollerForLiquidator {
    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint repayAmount
    ) external view returns (uint, uint);
}

// TODO : SECURITY : Add 'inMotion' flag and turn it off on function end (modifier?)
// TODO : add onlyAdmin modifier
// TODO : add admin setter
// TODO : add withdraw tokens (profits) function
/**
 * @title Ola's MultiVenueFlashLiquidator
 * @notice A 'self sustaining' liquidator based on a V2 (flash) swap.
 * @author Ola Finance
 */
contract MultiVenueFlashLiquidator is SingleOwnerLiquidator, V2PairReader {
    using SafeMath for uint;

    uint public constant NO_VENUE = 0;

    event NewVenueApproved(address indexed venueFactory, bytes32 codeHash, uint venueFeeNumerator, uint venueFeeDenominator, uint index);

    // to record profit in callback
    uint public stateProfit;

    uint venueCounter;

    // Venue id -> Factory address
    mapping(uint => address) public factories;
    // Venue id -> Pair initialization code
    mapping(uint => bytes32) public pairsCodeHashes;

    // Venue factory address => Index in this liquidator
    mapping(address => uint) public venueToIndex;

    // Represents a fractional fee
    struct VenueFee {
        uint numerator;
        uint denominator;
    }

    // Venue id -> VenueFee
    mapping(uint => VenueFee) internal venuesFees;

    constructor(address wrappedNative) SingleOwnerLiquidator(wrappedNative) {
    }

    receive() external payable override {}

    // **** Public views ****
    function isVenueApproved(address venueFactory) public view returns (bool) {
        return venueToIndex[venueFactory] > 0;
    }

    // **** ADMIN ****

    /**
     * Approves a new venue to be used
     */
    function approveVenue(address venueFactory, bytes32 codeHash, uint venueFeeNumerator, uint venueFeeDenominator) external onlyOwner {
        require(venueFactory != address(0), "Invalid factory address");

        // Idempotent
        if (isVenueApproved(venueFactory)) {
            return;
        }

        uint newIndex = venueCounter + 1;

        factories[newIndex] = venueFactory;
        pairsCodeHashes[newIndex] = codeHash;
        venuesFees[newIndex] = VenueFee({
            numerator:venueFeeNumerator,
            denominator:venueFeeDenominator
        });

        // Indicate venue is supported
        venueToIndex[venueFactory] = newIndex;

        // Update counter
        venueCounter = newIndex;

        emit NewVenueApproved(venueFactory, codeHash, venueFeeNumerator, venueFeeDenominator, newIndex);
    }

    // **** Liquidations ****

    /**
     * @param maxAmountInCallbackSwap Allows to limit the amount sent to the callback pair (in collateral asset) in return for the amount received from the callback pair (in borrowed asset).
     * @param minAmountOutFinalSwap Allows to limit the amount received from the final pair (in wNative) in return for the amount sent to the final pair (in collateral asset gained).
     * return amountInLiquidation is for simulation to get maxAmountIn callback pair
     *                            (e.g. for a safety buffer of 10% : use maxAmountInCallbackSwap = 1.1 * amountInLiquidation)
     * return netProfit is for simulation to get minAmountOut final pair
     *                  (e.g. for a safety buffer of 10% : use minAmountOutFinalSwap = 0.9 * netProfit)
     */
    function flashLiquidatePosition(
        uint venue,
        address cTokenBorrow,
        address borrower,
        uint repayAmount,
        address cTokenCollateral,
        uint maxAmountInCallbackSwap,
        // note : 0 for no final swap
        uint venueFinalSwap,
        // address tokenOutFinalSwap - for now we use wNative
        uint minAmountOutFinalSwap
    )
    external
    returns (uint amountInLiquidation, uint netProfit)
    {
        (uint _amountInLiquidation, address underlyingCollateral) = buildSwapCallbackPayloadAndSwap(venue, cTokenBorrow, cTokenCollateral, borrower, repayAmount, maxAmountInCallbackSwap, address(0), NO_VENUE);
        amountInLiquidation = _amountInLiquidation;

        // DEV_NOTE : The callback is locked in order to ensure 'stateProfit' will always have the proper value
        //            (only set in the callback)
        netProfit = stateProfit;
        stateProfit = 0;

        if (venueFinalSwap > 0) {
            require(underlyingCollateral != W_NATIVE, "already W_NATIVE");
            // if we started with 0 balance in underlyingCollateral netProfit == IERC20(underlyingCollateral)).balanceOf(address(this))
            netProfit = swapExactIn(venueFinalSwap, underlyingCollateral, W_NATIVE, netProfit, minAmountOutFinalSwap, address(0));
        }
    }

    function flashLiquidatePositionWithConnector(
        uint venue,
        address cTokenBorrow,
        address borrower,
        uint repayAmount,
        address cTokenCollateral,
        uint venueConnector,
        address tokenConnector,
        uint maxAmountInCallbackSwap,
        // note : 0 for no final swap
        uint venueFinalSwap,
        // address tokenOutFinalSwap - for now we use W_NATIVE
        uint minAmountOutFinalSwap
    )
    external
    returns (uint amountInLiquidation, uint netProfit)
    {
        address underlyingCollateral;
        (amountInLiquidation, underlyingCollateral) = buildSwapCallbackPayloadAndSwap(venue, cTokenBorrow, cTokenCollateral, borrower, repayAmount, maxAmountInCallbackSwap, tokenConnector, venueConnector);

        // DEV_NOTE : The callback is locked in order to ensure 'stateProfit' will always have the proper value
        //            (only set in the callback)
        netProfit = stateProfit;
        stateProfit = 0;

        if (venueFinalSwap > 0) {
            require(underlyingCollateral != W_NATIVE, "already W_NATIVE");
            netProfit = swapExactIn(venueFinalSwap, underlyingCollateral, W_NATIVE, netProfit, minAmountOutFinalSwap, address(0));
        }
    }

    function flashLiquidatePositionSingle(
        uint venue,
        address cToken,
        address borrower,
        uint repayAmount,
        address tokenFlash,
        // note : 0 for no final swap
        uint venueFinalSwap,
        // address tokenOutFinalSwap - for now we use W_NATIVE
        uint minAmountOutFinalSwap
    )
    external
    returns (uint netProfit)
    {
        address underlying = buildSwapCallbackPayloadAndSwapSingle(venue, cToken, borrower, repayAmount, tokenFlash);

        // DEV_NOTE : The callback is locked in order to ensure 'stateProfit' will always have the proper value
        //            (only set in the callback)
        netProfit = stateProfit;
        stateProfit = 0;

        if (venueFinalSwap > 0) {
            require(underlying != W_NATIVE, "already W_NATIVE");
            netProfit = swapExactIn(venueFinalSwap, underlying, W_NATIVE, netProfit, minAmountOutFinalSwap, address(0));
        }
    }

    struct CallbackData {
        // to verify pair
        uint venue;
        // (collateralToken/tokenConnector/flashTokenPair) to verify pair and to complete swap
        address tokenIn;
        // to verify profit
        uint underlyingCollateralBalanceBefore;
        // (borrowToken) to verify pair
        address tokenOut;
        // to complete swap
        uint amountIn;
        // address pair -- not necessary because it will be the msg.sender
        // for calling liquidateBorrow
        address cTokenBorrow;
        // for calling liquidateBorrow
        address borrower;
        // uint repayAmount -- not necessary because it is amoun0Out or amount1Out
        // for calling liquidateBorrow
        address cTokenCollateral;
        // for connectorSwap (0 if not used)
        uint venueConnector;
    }

    // **** V2 callback ****

    // DEV_NOTE : Add flag to ensure mid run
    function uniswapV2Call(address sender, uint amount0Out, uint amount1Out, bytes calldata _data) external {
        swapV2CallInternal(sender, amount0Out, amount1Out, _data);
    }

    function pancakeCall(address sender, uint amount0Out, uint amount1Out, bytes calldata _data) external {
        swapV2CallInternal(sender, amount0Out, amount1Out, _data);
    }

    function swapV2CallInternal(address sender, uint amount0Out, uint amount1Out, bytes calldata _data) internal {
        // TODO : CRITICAL : Check for 'inMotion' flag
        CallbackData memory data = abi.decode(_data, (CallbackData));

        // SECURITY :Anyone can make the pair call this function ! Better maker sure it is only the rightful pair
        address rightfulPair = pairForVenue(data.venue, data.tokenIn, data.tokenOut);
        require(msg.sender == rightfulPair, "invalid pair");

        uint amountToRepay = amount0Out > 0 ? amount0Out : amount1Out;


        // address underlyingBorrow = sanitizeUnderlying(data.cTokenBorrow);
        // uint cTokenCollateralAmountSeized = liquidatePositionInternal(data.cTokenBorrow, underlyingBorrow, data.borrower, amountToRepay, data.cTokenCollateral);

        address borrowUnderlying = CTokenInterfaceForLiquidator(data.cTokenBorrow).underlying();

        // The swap provided wNative tokens, we should unwrap the native coin in order to be able to repay the loan.
        if (borrowUnderlying == NATIVE) {
            IWETHForLiquidator(W_NATIVE).withdraw(amountToRepay);
        }

        uint cTokenCollateralAmountSeized = liquidatePosition(data.cTokenBorrow, data.borrower, amountToRepay, data.cTokenCollateral, false);

        // note : this might fail if there's no liq in the market
        require(CTokenInterfaceForLiquidator(data.cTokenCollateral).redeem(cTokenCollateralAmountSeized) == 0, "redeem fail");

        // The swap expects wNative tokens, we should wrap the native coin in order to be able to pay for the swap.
        if (CTokenInterfaceForLiquidator(data.cTokenCollateral).underlying() == NATIVE) {
            uint selfBalanceNative = address(this).balance;
            IWETHForLiquidator(W_NATIVE).deposit{value:selfBalanceNative}();
        }

        address underlyingCollateral = sanitizeUnderlying(data.cTokenCollateral);
        uint underlyingCollateralBalanceAfter = IERC20(underlyingCollateral).balanceOf(address(this));

        // direct swap: underlyingCollateral -> underlyingBorrow (without tokenConnector)
        if (data.tokenIn == underlyingCollateral) {
            address tokenIn = data.tokenIn;

            // only from flashLiquidateSingle()
            if (data.cTokenBorrow == data.cTokenCollateral) {
                tokenIn = data.tokenOut;
            }

            // DEV_NOTE : The first sub will fail in case the redeemed underlying are less than 'data.amountIn'
            //            This should not occur.
            //            The second one will fail if the amount of underlying received by redeeming the received collateral tokens
            //            is not enough to pay for the swap.
            uint balanceDiff = sub(underlyingCollateralBalanceAfter, data.underlyingCollateralBalanceBefore, "Less balance then before");
            stateProfit = sub(balanceDiff, data.amountIn, "Redeem not covering swap");

            // TODO : use safe transfer instead
            IERC20(tokenIn).transfer(rightfulPair, data.amountIn);
            return;
        } else {
            // connector swap: underlyingCollateral -> tokenConnector -> underlyingBorrow (with tokenConnector)
            uint maxAmountIn = sub(underlyingCollateralBalanceAfter, data.underlyingCollateralBalanceBefore, "underlyingCollateralBalanceAfter");
            // note : handles transfer of data.amountIn tokens (of type data.tokenIn) to pair
            uint amountIn = swapExactOut(data.venueConnector, underlyingCollateral, data.tokenIn, data.amountIn, maxAmountIn, rightfulPair);
            stateProfit = sub(maxAmountIn, amountIn, "maxAmountIn");
            return;
        }
    }

    // TODO : add safeTrnasfer
    // TODO : add general function call to external functions in other contracts

    // **** Swap Venues ****

    /**
     * calculates the CREATE2 address for a pair without making any external calls
     */
    function pairForVenue(uint venueCode, address tokenA, address tokenB) internal view returns (address pair) {
        address factory = factories[venueCode];

        require(factory != address(0), "unknown factory");

        bytes32 pairCode = pairsCodeHashes[venueCode];

        if (pairCode == bytes32(0)) {
            // in case of unknown pairCode
            pair = pairForFromFactory(factory, tokenA, tokenB);
        } else {
            // Local calculation -- saving gas
            pair = pairFor(factory, pairCode, tokenA, tokenB);
        }
    }

    // **** LOGIC ****

    function buildSwapCallbackPayloadAndSwap(uint venue, address cTokenBorrow, address cTokenCollateral, address borrower, uint repayAmount, uint maxAmountIn, address tokenConnector, uint venueConnector) internal returns (uint amountInLiquidation, address underlyingCollateral) {
        repayAmount = getSafeRepayAmount(cTokenBorrow, cTokenCollateral, borrower, repayAmount);

        underlyingCollateral = sanitizeUnderlying(cTokenCollateral);
        address underlyingBorrow = sanitizeUnderlying(cTokenBorrow);

        // NOTE : comparing addresses
        uint amount0Out;
        uint amount1Out;

        // In case of a connector token, we swap underlyingBorrow for tokenConnector
        if (tokenConnector == address(0)) {
            amount0Out = underlyingBorrow < underlyingCollateral ? repayAmount : 0;
            amount1Out = underlyingBorrow > underlyingCollateral ? repayAmount : 0;
        } else {
            amount0Out = underlyingBorrow < tokenConnector ? repayAmount : 0;
            amount1Out = underlyingBorrow > tokenConnector ? repayAmount : 0;
        }


        require(amount0Out == 0 || amount1Out == 0, "amountsOut > 0");

        (address pair, CallbackData memory callbackData) = buildSwapCallbackPayload(venue, cTokenBorrow, cTokenCollateral, borrower, repayAmount, maxAmountIn, tokenConnector, venueConnector);
        amountInLiquidation = callbackData.amountIn;

        // Note : This will perform a swap using this contracts 'uniswapV2Call' as a callback
        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), abi.encode(callbackData));
    }

    function buildSwapCallbackPayloadAndSwapSingle(uint venue, address cToken, address borrower, uint repayAmount, address tokenFlash) internal returns (address underlying) {
        repayAmount = getSafeRepayAmount(cToken, cToken, borrower, repayAmount);

        underlying = sanitizeUnderlying(cToken);

        // NOTE : comparing addresses
        uint amount0Out = underlying < tokenFlash ? repayAmount : 0;
        uint amount1Out = underlying > tokenFlash ? repayAmount : 0;
        require(amount0Out == 0 || amount1Out == 0, "amountsOut > 0");

        (address pair, CallbackData memory callbackData) = buildSwapCallbackPayloadSingle(venue, cToken, borrower, repayAmount, tokenFlash);

        // Note : This will perform a swap using this contracts 'uniswapV2Call' as a callback
        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), abi.encode(callbackData));
    }

    function buildSwapCallbackPayload(uint venue, address cTokenBorrow, address cTokenCollateral, address borrower, uint repayAmount, uint maxAmountIn, address tokenConnector, uint venueConnector) internal returns (address, CallbackData memory) {

        if (tokenConnector == address(0)) {
            tokenConnector = sanitizeUnderlying(cTokenCollateral);
        }

        // note : will fail if underlyingBorrow == underlyingCollateral
        (address pair, uint tokenConnectorAmountIn) = calculatePairAndConnectorAmountIn(venue, cTokenBorrow, tokenConnector, repayAmount);
        // DAVID : this check is actually fine here as we're trying to limit the amount that we will send *to* the pair
        require(maxAmountIn == 0 || tokenConnectorAmountIn <= maxAmountIn, "MAI");

        return (pair, buildCallbackData(
            venue,
            tokenConnector,
            cTokenCollateral,
            cTokenBorrow,
            tokenConnectorAmountIn,
            borrower,
            venueConnector
        ));
    }

    function buildSwapCallbackPayloadSingle(uint venue, address cToken, address borrower, uint repayAmount, address tokenFlash) internal returns (address, CallbackData memory ) {
        (address pair, uint underlyingAmountIn) = calculatePairAndAmountInFlashLoan(venue, cToken, tokenFlash, repayAmount);

        return (pair, buildCallbackData(
            venue,
            tokenFlash,
            cToken,
            cToken,
            underlyingAmountIn,
            borrower,
            NO_VENUE
        ));
    }

    function calculatePairAndConnectorAmountIn(uint venue, address cTokenBorrow, address tokenConnector, uint repayAmount) internal returns (address pair, uint tokenConnectorAmountIn) {
        address underlyingBorrow = sanitizeUnderlying(cTokenBorrow);
        pair = pairForVenue(venue, tokenConnector, underlyingBorrow);

        VenueFee memory venueFee = venuesFees[venue];
        tokenConnectorAmountIn = calculateAmountIn(pair, tokenConnector, underlyingBorrow, repayAmount, venueFee);
    }

    function calculatePairAndAmountInFlashLoan(uint venue, address cToken, address tokenFlash, uint repayAmount) internal returns (address pair, uint tokenConnectorAmountIn) {
        address underlying = sanitizeUnderlying(cToken);
        pair = pairForVenue(venue, tokenFlash, underlying);

        VenueFee memory venueFee = venuesFees[venue];
        tokenConnectorAmountIn = calculateAmountInFlashLoan(repayAmount, venueFee);
    }

    function buildCallbackData(uint venue, address tokenIn, address cTokenCollateral, address cTokenBorrow,
                               uint amountIn,  address borrower, uint venueConnector) internal returns (CallbackData memory callbackData){

        address underlyingCollateral = sanitizeUnderlying(cTokenCollateral);
        address underlyingBorrow = sanitizeUnderlying(cTokenBorrow);

        // TODO : C.F.H : Understand this function and then merge/reuse with the 'same asset liquidation'
        callbackData = CallbackData({
            venue : venue,
            tokenIn : tokenIn,
            underlyingCollateralBalanceBefore : IERC20(underlyingCollateral).balanceOf(address(this)),
            tokenOut : underlyingBorrow,
            amountIn : amountIn,
            cTokenBorrow : cTokenBorrow,
            borrower : borrower,
            cTokenCollateral : cTokenCollateral,
            venueConnector : venueConnector
        });
    }

    // TODO : Find better names for function params
    // @notice Calculates the required 'in' amount in order to get the wanted 'out' amount
    function calculateAmountIn(address pair, address underlyingCollateral, address underlyingBorrow, uint wantedOutAmount, VenueFee memory venueFee) internal returns (uint requiredAmountIn) {
        (uint reserveUnderlyingCollateral, uint reserveUnderlyingBorrow) = getReserves(pair, underlyingCollateral, underlyingBorrow);
        requiredAmountIn = getAmountIn(wantedOutAmount, reserveUnderlyingCollateral, reserveUnderlyingBorrow, venueFee.numerator, venueFee.denominator);
    }

    /**
     * Calculates the required amount for a same-token swap.
     */
    function calculateAmountInFlashLoan(uint amountOut, VenueFee memory venueFee) internal returns (uint requiredAmountIn) {
        requiredAmountIn = (amountOut * venueFee.denominator) / venueFee.numerator;
    }

    // **** Direct pair interaction ****

    function swapExactIn(uint venue, address tokenIn, address tokenOut, uint amountIn, uint minAmountOut, address to) internal returns (uint amountOutCalculated) {
        uint tokenOutBalanceBefore = IERC20(tokenOut).balanceOf(address(this));
        
        address pair = pairForVenue(venue, tokenIn, tokenOut);
        (uint reserveIn, uint reserveOut) = getReserves(pair, tokenIn, tokenOut);
        VenueFee memory venueFee = venuesFees[venue];
        amountOutCalculated = getAmountOut(amountIn, reserveIn, reserveOut, venueFee.numerator, venueFee.denominator);
        doSwap(pair, tokenIn, tokenIn < tokenOut, amountIn, amountOutCalculated, to);
        
        uint tokenOutBalanceAfter = IERC20(tokenOut).balanceOf(address(this));
        require(tokenOutBalanceAfter > tokenOutBalanceBefore, "tokenOutBalanceAfter < tokenOutBalanceBefore");
        uint actualAmountOut = tokenOutBalanceAfter - tokenOutBalanceBefore;
        require(minAmountOut == 0 || actualAmountOut >= minAmountOut, "MAO");
    }

    function swapExactOut(uint venue, address tokenIn, address tokenOut, uint amountOut, uint maxAmountIn, address to) internal returns (uint amountInCalculated) {
        address pair = pairForVenue(venue, tokenIn, tokenOut);
        (uint reserveIn, uint reserveOut) = getReserves(pair, tokenIn, tokenOut);
        VenueFee memory venueFee = venuesFees[venue];
        amountInCalculated = getAmountIn(amountOut, reserveIn, reserveOut, venueFee.numerator, venueFee.denominator);
        // DAVID : this check is actually fine here as we're trying to limit the amount that we will send *to* the pair
        require(maxAmountIn == 0 || amountInCalculated <= maxAmountIn, "MAO");
        doSwap(pair, tokenIn, tokenIn < tokenOut, amountInCalculated, amountOut, to);
    }

    function doSwap(address pair, address tokenIn, bool zeroForOne, uint amountIn, uint amountOut, address to) internal {
        // TODO : use safe transfer instead
        IERC20(tokenIn).transfer(pair, amountIn);

        uint amount0Out = zeroForOne ? 0 : amountOut;
        uint amount1Out = zeroForOne ? amountOut : 0;
        // require(amount0Out == 0 || amount1Out == 0, "amountsOut > 0");
        if (to == address(0)) {
            to = address(this);
        }
        // TODO : verify that the swap passes
        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, to, new bytes(0));
    }

    // **** Native-Erc20 safety ****
    function sanitizeUnderlying(address cToken) internal view returns (address underlying) {
        underlying = CTokenInterfaceForLiquidator(cToken).underlying();
        if (underlying == NATIVE) {
            underlying = W_NATIVE;
        }
    }


    // **** MATH ****

//    function sub(uint x, uint y) internal pure returns (uint z) {
//        z = x - y;
//        require(z <= x, 'sub: ds-math-sub-underflow');
//    }

    function sub(uint x, uint y, string memory errorMessage) internal pure returns (uint z) {
        z = x - y;
        require(z <= x, errorMessage);
    }

    // **** SIMULATE ****

//    /**
//     *
//     */
//    function checkMarketLiquidity(address cTokenBorrow, address cTokenCollateral, address borrower) external returns (uint repayAmount) {
//        repayAmount = getSafeRepayAmount(cTokenBorrow, cTokenCollateral, borrower, repayAmount);
//
//        address underlyingCollateral = sanitizeUnderlying(cTokenCollateral);
//        address underlyingBorrow = sanitizeUnderlying(cTokenBorrow);
//        address comptroller = CTokenInterfaceForLiquidator(cTokenBorrow).comptroller();
//
//        /* We calculate the number of collateral tokens that will be seized */
//        (uint amountSeizeError, uint seizeTokens) = ComptrollerForLiquidator(comptroller).liquidateCalculateSeizeTokens(cTokenBorrow, cTokenCollateral, repayAmount);
//        require(amountSeizeError == 0, "LIQUIDATE_COMPTROLLER_CALCULATE_AMOUNT_SEIZE_FAILED");
//
//        bool recalculateRepayAmount = false;
//
//        // verify that borrower has enough cTokenCollateral
//        if (IERC20(cTokenCollateral).balanceOf(borrower) < seizeTokens) {
//            seizeTokens = IERC20(cTokenCollateral).balanceOf(borrower);
//            recalculateRepayAmount = true;
//            // return false;
//        }
//
//        // verify that the collateral market has enough cash to redeem seizeTokens
//        uint exchangeRate = CTokenInterfaceForLiquidator(cTokenCollateral).exchangeRateStored();
//        // redeemAmount = redeemTokens x exchangeRateCurrent = seizeTokens * exchangeRate
//        uint seizeAmount = (exchangeRate * seizeTokens) / 1e18;
//        // DAVID : what is the difference between gatCash and getCashPrior ?
//        if (CTokenInterfaceForLiquidator(cTokenCollateral).getCash() < seizeAmount) {
//            // TODO : recalculate repayAmount
//            uint maxSeizeAmount = CTokenInterfaceForLiquidator(cTokenCollateral).getCash();
//            seizeTokens = (maxSeizeAmount * 1e18) / exchangeRate;
//            recalculateRepayAmount = true;
//            // return false;
//        }
//
    //            repayAmount = liquidateCalculateSeizeTokensReverse(cTokenBorrowed, cTokenCollateral, seizeTokens);
    // //        if (recalculateRepayAmount) {
//       }
//
//        return repayAmount;
//    }
//
//    function liquidateCalculateSeizeTokensReverse(address cTokenBorrowed, address cTokenCollateral, uint actualSeizeTokens) internal view returns (uint) {
//        /* Read oracle prices for borrowed and collateral markets */
//        // TODO : need to call registry's getPriceForUnderling()
//        uint priceBorrowed = getUnderlyingPriceForCToken(cTokenBorrowed);
//        uint priceCollateral = getUnderlyingPriceForCToken(cTokenCollateral);
//        if (priceBorrowed == 0 || priceCollateral == 0) {
//            return 0;
//        }
//
//        /*
//         * Get the exchange rate and calculate the number of collateral tokens to seize:
//         *  seizeAmount = actualRepayAmount * liquidationIncentive * priceBorrowed / priceCollateral
//         *  seizeTokens = seizeAmount / exchangeRate
//         *   = actualRepayAmount * (liquidationIncentive * priceBorrowed) / (priceCollateral * exchangeRate)
//         *
//         * OR:
//         *
//         *  actualRepayAmount = seizeTokens * (priceCollateral * exchangeRate) / liquidationIncentive * priceBorrowed)
//         */
//        uint exchangeRate = CTokenInterfaceForLiquidator(cTokenCollateral).exchangeRateStored();
//        // TODO : fix fetching liquidationIncentive
//        uint liquidationIncentive = markets[cTokenCollateral].liquidationIncentiveMantissa;
//        uint repayAmount;
//        uint numerator;
//        Exp memory denominator;
//        Exp memory ratio;
//
//        // OLA_ADDITIONS : Added a direct read for the market 'liquidationIncentiveMantissa'.
//        // notice: will be 0 for unsupported 'cTokenCollateral'
//        denominator = (liquidationIncentive * priceBorrowed) / 1e18;
//        numerator = (priceCollateral * exchangeRate) / 1e18;
//        ratio = (numerator * 1e18) / denominator;
//
//        repayAmount = (ratio * actualSeizeTokens) / 1e18;
//
//        return repayAmount;
//    }
}

pragma solidity ^0.7.6;

import "@openzeppelin/contracts/math/SafeMath.sol";

interface IUniswapV2PairForReader {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IUniswapV2PairFactoryForReader {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract V2PairReader {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, bytes32 pairCodeHash, address tokenA, address tokenB) internal view returns (address pair) {
        // already done outside ?
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                pairCodeHash
            ))));
    }

    function pairForFromFactory(address factory, address tokenA, address tokenB) internal view returns (address pair) {
        pair = IUniswapV2PairFactoryForReader(factory).getPair(tokenA, tokenB);
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address pair, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2PairForReader(pair).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint feeNumerator, uint feeDenominator) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'getAmountOut:UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'getAmountOut:UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        // note: in ApeSwap: 998; in PancakeSwap: 9975
        uint amountInWithFee = amountIn.mul(feeNumerator);
        uint numerator = amountInWithFee.mul(reserveOut);
        // note: in PancakeSwap: 10000
        uint denominator = reserveIn.mul(feeDenominator).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut, uint feeNumerator, uint feeDenominator) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'getAmountOut:UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'getAmountOut:UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        // note: in PancakeSwap: 10000
        uint numerator = reserveIn.mul(amountOut).mul(feeDenominator);
        // note: in ApeSwap: 998; in PancakeSwap: 9975
        require(reserveOut > amountOut, "reserveOut < amountOut");
        uint denominator = reserveOut.sub(amountOut).mul(feeNumerator);
        amountIn = (numerator / denominator).add(1);
    }
}

pragma solidity ^0.7.6;

import "./LiquidatorBase.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

interface IUniswapV2Pair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
}

contract HecLiquidator is LiquidatorBase {
    using SafeMath for uint256;

    address public owner;
    address public backupOwner;
    address public authorizedLiquidator;
    address public backupAuthorizedLiquidator;

    // Spooky params
    address private constant SPOOKY_FACTORY =
        address(0x152eE697f2E276fA89E96742e9bB9aB1F2E61bE3);
    uint256 internal constant SPOOKY_FEE_NUMER = 998;
    bytes32 internal constant SPOOKY_INIT_CODE_HASH =
        0xcdf2deca40a0bd56de8e3ce5c7df6727e5b1bf2ac96f283fa9c4b3e6b42ea9d2;

    // Spirit params
    address private constant SPIRIT_FACTORY =
        address(0xEF45d134b73241eDa7703fa787148D9C9F4950b0);
    uint256 internal constant SPIRIT_FEE_NUMER = 997;
    bytes32 internal constant SPIRIT_INIT_CODE_HASH =
        0xe242e798f6cee26a9cb0bbf24653bf066e5356ffeac160907fe2cc108e238617;

    uint256 internal constant FEE_DENOM = 1000;

    constructor(
        address owner_,
        address backupOwner_,
        address authorizedLiquidator_,
        address backupAuthorizedLiquidator_,
        address wNative_
    ) LiquidatorBase(wNative_) {
        owner = owner_;
        backupOwner = backupOwner_;
        authorizedLiquidator = authorizedLiquidator_;
        backupAuthorizedLiquidator = backupAuthorizedLiquidator_;
    }

    receive() external payable {}

    // ****** ownership ******

    function isOwner() internal view returns (bool) {
        return msg.sender == owner || msg.sender == backupOwner;
    }

    function isAuthorized() internal view returns (bool) {
        return
            msg.sender == authorizedLiquidator ||
            msg.sender == backupAuthorizedLiquidator ||
            isOwner();
    }

    function _onlyOwner() internal view {
        require(isOwner(), "!Owner");
    }

    function _onlyAuthorized() internal view {
        require(isAuthorized(), "!Authorized");
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    modifier onlyAuthorized() {
        _onlyAuthorized();
        _;
    }

    function set0wner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function setBackup0wner(address newOwner) external onlyOwner {
        backupOwner = newOwner;
    }

    function setAuthorizedLiquidator(address newAuthorized) external onlyOwner {
        authorizedLiquidator = newAuthorized;
    }

    function setBackupAuthorizedLiquidator(address newAuthorized)
        external
        onlyOwner
    {
        backupAuthorizedLiquidator = newAuthorized;
    }

    function withdrawToken(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        if (amount == 0) {
            amount = IERC20ForLiquidator(token).balanceOf(address(this));
        }
        TransferHelper.safeTransfer(token, to, amount);
    }

    function withdrawNative(address to, uint256 amount) external onlyOwner {
        if (amount == 0) {
            amount = address(this).balance;
        }
        TransferHelper.safeTransferETH(to, amount);
    }

    // External functionality
    function liquidate(
        address cTokenBorrow,
        address borrower,
        uint256 repayAmount,
        address cTokenCollateral,
        uint256 maxAmountIn,
        address[] calldata path,
        bool[] calldata spookySpirit // spooky: false, spirit: true
    )
        external
        onlyAuthorized
        returns (uint256 swapAmountIn, uint256 collateralAmountOut)
    {
        address underlyingBorrow = sanitizeUnderlying(cTokenBorrow);
        address underlyingCollateral = sanitizeUnderlying(cTokenCollateral);
        uint256 underlyingCollateralBalanceBefore = IERC20ForLiquidator(
            underlyingCollateral
        ).balanceOf(address(this));

        repayAmount = getSafeRepayAmount(
            cTokenBorrow,
            cTokenCollateral,
            borrower,
            repayAmount
        );
        if (path.length == 0) {
            swapAmountIn = 0;
        } else {
            require(path.length >= 2, "path.length = 1");
            require(
                underlyingBorrow == path[path.length - 1],
                "bad last token in path"
            );
            swapAmountIn = swapTokensForExactTokens(
                repayAmount,
                maxAmountIn,
                path,
                spookySpirit
            );
        }

        if (underlyingBorrow == W_NATIVE) {
            IWETHForLiquidator(W_NATIVE).withdraw(repayAmount);
        }

        uint256 cTokenCollateralAmountSeized = liquidatePositionAndRedeemInternal(
            cTokenBorrow,
            borrower,
            repayAmount,
            cTokenCollateral
        );
        if (underlyingCollateral == W_NATIVE) {
            IWETHForLiquidator(W_NATIVE).deposit{
                value: address(this).balance
            }();
        }

        uint256 underlyingCollateralBalanceAfter = IERC20ForLiquidator(
            underlyingCollateral
        ).balanceOf(address(this));
        require(
            underlyingCollateralBalanceAfter >
                underlyingCollateralBalanceBefore,
            "no collateral gain"
        );
        collateralAmountOut =
            underlyingCollateralBalanceAfter -
            underlyingCollateralBalanceBefore;
    }

    function genericCall(address target, bytes calldata data)
        external
        onlyOwner
        returns (bytes memory returnData)
    {
        bool success;
        (success, returnData) = target.call(data);
        require(success, "Call failed");
    }

    // ****** Modified UniswapV2 Library ******

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        bool spookySpirit,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        (address factory, bytes32 initCodeHash) = spookySpirit
            ? (SPIRIT_FACTORY, SPIRIT_INIT_CODE_HASH)
            : (SPOOKY_FACTORY, SPOOKY_INIT_CODE_HASH);
        pair = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        initCodeHash
                    )
                )
            )
        );
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        bool spookySpirit,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(
            pairFor(spookySpirit, tokenA, tokenB)
        ).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut,
        uint256 feeNumerator,
        uint256 feeDenominator
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        require(
            reserveOut > amountOut,
            "UniswapV2Library: AMOUNT_OUT_EXCEEDS_RESERVE"
        );
        uint256 numerator = reserveIn.mul(amountOut).mul(feeDenominator);
        uint256 denominator = reserveOut.sub(amountOut).mul(feeNumerator);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        bool[] memory spookySpirit,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        require(
            spookySpirit.length == path.length - 1,
            "UniswapV2Library: SPOOKY_SPIRIT_WRONG_LENGTH"
        );
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                spookySpirit[i - 1],
                path[i - 1],
                path[i]
            );
            uint256 feeNumer = spookySpirit[i - 1]
                ? SPIRIT_FEE_NUMER
                : SPOOKY_FEE_NUMER;
            amounts[i - 1] = getAmountIn(
                amounts[i],
                reserveIn,
                reserveOut,
                feeNumer,
                FEE_DENOM
            );
        }
    }

    // ****** Modified UniswapV2 Router ******

    // requires the initial amount to have already been sent to the first pair
    function _swap(
        bool[] memory spookySpirit,
        uint256[] memory amounts,
        address[] memory path,
        address _to
    ) internal virtual {
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
            address to = i < path.length - 2
                ? pairFor(spookySpirit[i + 1], output, path[i + 2])
                : address(this);
            IUniswapV2Pair(pairFor(spookySpirit[i], input, output)).swap(
                amount0Out,
                amount1Out,
                to,
                new bytes(0)
            );
        }
    }

    function swapTokensForExactTokens(
        uint256 amountOut, // repayAmount
        uint256 amountInMax,
        address[] calldata path,
        // to = address(this)
        bool[] memory spookySpirit
    ) internal returns (uint256) {
        uint256[] memory amounts = new uint256[](path.length);
        amounts = getAmountsIn(spookySpirit, amountOut, path);
        if (amountInMax > 0) {
            require(
                amounts[0] <= amountInMax,
                "UniswapV2Router: EXCESSIVE_INPUT_AMOUNT"
            );
        }
        TransferHelper.safeTransfer(
            path[0],
            pairFor(spookySpirit[0], path[0], path[1]),
            amounts[0]
        );
        _swap(spookySpirit, amounts, path, address(this));
        return amounts[0];
    }

    // ****** cToken utils ******

    function sanitizeUnderlying(address cToken)
        internal
        view
        returns (address underlying)
    {
        underlying = CTokenInterfaceForLiquidator(cToken).underlying();
        if (underlying == NATIVE) {
            underlying = W_NATIVE;
        }
    }

    // ****** Admin ******
}

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

pragma solidity 0.7.6;

interface IUniswapV2FactoryForBananaSwapper {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2PairForBananaSwapper {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

contract BananaBridgedSwapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IUniswapV2FactoryForBananaSwapper public immutable factory;
    uint public factoryNumerator;
    uint public factoryDenominator;
    address public immutable banana;
    address public immutable wBNB;

    mapping(address => address) internal _bridges;

    event LogBridgeSet(address indexed token, address indexed bridge);
    event LogConvert(
        address indexed server,
        address indexed token,
        uint256 amount,
        uint256 amountBANANA
    );

    constructor(
        address _factory,
        uint _factoryNumerator,
        uint _factoryDenominator,
        address _banana,
        address _wBNB
    ) {
        factory = IUniswapV2FactoryForBananaSwapper(_factory);
        banana = _banana;
        wBNB = _wBNB;

        factoryNumerator= _factoryNumerator;
        factoryDenominator= _factoryDenominator;
    }

    function bridgeFor(address token) public view returns (address bridge) {
        bridge = _bridges[token];
        if (bridge == address(0)) {
            bridge = wBNB;
        }
    }

    function setBridgeInternal(address token, address bridge) internal {
        // Checks
        require(
            token != banana && token != wBNB && token != bridge,
            "BananaBridgedSwapper: Invalid bridge"
        );

        // Effects
        _bridges[token] = bridge;
        emit LogBridgeSet(token, bridge);
    }

    function _convert(address token) internal returns (uint bananaOut) {
        uint selfBalance = IERC20(token).balanceOf(address(this));
        bananaOut = _convertStep(token, selfBalance);

        emit LogConvert(
            msg.sender,
            token,
            selfBalance,
            bananaOut
        );
    }

    function _convertStep(
        address token,
        uint256 amount
    ) internal returns (uint256 bananaOut) {
        // Interactions
        if (token == banana) {
            // Assuming amount=selfBalance
            bananaOut = amount;
        } else if (token == wBNB) {
            bananaOut = _toBANANA(wBNB, amount);
        } else {
            // bridgeFor should return wBNB as default
            address bridge = bridgeFor(token);
            amount = _swap(token, bridge, amount, address(this));
            bananaOut = _convertStep(bridge, amount);
        }
    }

    function _swap(
        address fromToken,
        address toToken,
        uint256 amountIn,
        address to
    ) internal returns (uint256 amountOut) {
        // Checks
        IUniswapV2PairForBananaSwapper pair = IUniswapV2PairForBananaSwapper(factory.getPair(fromToken, toToken));
        require(address(pair) != address(0), "BananaBridgedSwapper: Cannot convert - NoPair");

        // Interactions
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        uint256 amountInWithFee = amountIn.mul(factoryNumerator);
        if (fromToken == pair.token0()) {
            amountOut = amountInWithFee.mul(reserve1) / reserve0.mul(factoryDenominator).add(amountInWithFee);
            IERC20(fromToken).safeTransfer(address(pair), amountIn);
            pair.swap(0, amountOut, to, new bytes(0));
            // TODO: Add maximum slippage?
        } else {
            amountOut = amountInWithFee.mul(reserve0) / reserve1.mul(factoryDenominator).add(amountInWithFee);
            IERC20(fromToken).safeTransfer(address(pair), amountIn);
            pair.swap(amountOut, 0, to, new bytes(0));
            // TODO: Add maximum slippage?
        }
    }

    function _toBANANA(address token, uint256 amountIn) internal returns (uint256 amountOut)
    {
        amountOut = _swap(token, banana, amountIn, address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./BananaBridgedSwapper.sol";

interface IFeesHandler {
    function handleFee(address token) external;
    function handleManyFees(address[] calldata tokens) external;
}

interface IOTokenForBananaMaker {
    function mint(uint mintAmount) external returns (uint);
}

interface IWBNBForBananaMaker {
    function deposit() external payable;
}

/**
 * @title Ola's BananaMaker Contract
 * @notice Implements ApeSwap governance decision :
 * https://snapshot.org/#/apeswap-finance.eth/proposal/0x6a0f98bb9ba4c45a1b887a13a16dd9633b1043211384fcb80107967e6e56bd5b
 * @author Ola
 *
 * Handles the existing balance of the given asset by the following logic :
 * 1. Send 10% of self balance to the Ape boss.
 * 2. Convert rest of self balance to BANANA.
 * 3. Distribute the gained BANANA in the following way:
 * - 30% will be burned.
 * - 55% will be used to mint oBanana (which will then be burned).
 * - 15% will go to Ola boss.
 *
 */
contract BananaMaker is Ownable, BananaBridgedSwapper, IFeesHandler {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event ApeBossPartSent(address indexed apeBoss, address indexed asset, uint amount);
    event BananaDistributed(address indexed olaBoss, uint burnedBananas, uint lockedBananas, uint olaBananas);

    address public constant burnAddress = 0x000000000000000000000000000000000000dEaD;

    address public apeBoss;
    address public olaBoss;
    address public oBananaMarket;

    uint fullUnit = 1e18;

    uint tenPercent = 10e16;
    uint thirtyPercent = 30e16;
    uint fiftyFivePercent = 55e16;
    // uint fifteenPercent = 15e16;

    /**
     * Handles the existing balance of the given asset
     * @param token The asset in need of a handling
     */
    function handleFee(address token) external override onlyEOA {
        handleNonBananaBalance(token);

        handleBananaBalance();
    }

    /**
     * Handles the existing balance of the given assets
     * @param tokens The assets in need of a handling
     */
    function handleManyFees(address[] calldata tokens) external override onlyEOA {

        // Sanity, if BANANA is one of the given assets, it has to be the first one.
        uint length = tokens.length;
        for (uint i = 0; i < length; i++) {
            require(tokens[i] != banana || i == 0, "BANANA must be first");
        }

        handleManyFeesInternal(tokens);
    }

    function wrapBNB() external onlyEOA {
        wrapAllBNBInternal();
    }

    constructor(
        address _factory,
        uint _factoryNumerator,
        uint _factoryDenominator,
        address _banana,
        address _wBNB,
        address _apeBoss,
        address _olaBoss,
        address _oBananaMarket
    )  BananaBridgedSwapper(_factory, _factoryNumerator, _factoryDenominator, _banana, _wBNB){
        apeBoss = _apeBoss;
        olaBoss = _olaBoss;
        oBananaMarket = _oBananaMarket;

        ERC20(_banana).approve(oBananaMarket, uint(-1));
    }

    /**
     * Does nothing but wrap given BNB to wBNB to standardize the process.
     * @param token The asset in need of a bridge on it's way to BANANA
     * @param bridge THe asset to use as a bridge on the way to BANANA
     */
    function setBridge(address token, address bridge) external onlyOwner {
        setBridgeInternal(token, bridge);
    }

    /**
     * Handles the existing balance of the given assets i.e distribute 10% to the ape boss and
     * convert the rest to BANANA.
     * @notice CRITICAL : If BANANA is one of the given tokens, it must be the first one !
     * @param tokens The assets in need of a handling
     */
    function handleManyFeesInternal(address[] calldata tokens) internal {
        // First, distribute and convert all of the assets
        uint length = tokens.length;
        for (uint i = 0; i < length; i++) {
            handleNonBananaBalance(tokens[i]);
        }

        // Then, handle all accumulated banana
        handleBananaBalance();
    }

    /**
     * Sends 10% of self balance in token to boss ape and convert the rest to BANANAS
     */
    function handleNonBananaBalance(address token) internal returns (uint bananaGained) {
        // In the case of wBNB, we handle the situation where there might be some unwrapped BNB to use
        if (token == wBNB) {
            wrapAllBNBInternal();
        }

        // Send 10% of existing balance to Ape boss
        (uint bossPart, uint reminder) = sendAppBossPart(token);

        // Convert remaining balance to banana
        bananaGained = _convert(token);
    }

    /**
     * Burns, supplies and distribute all self balance in BANANA,
     */
    function handleBananaBalance() internal {
        // Distribute banana by percentages
        (uint burnPart, uint lockPart, uint olaPart) = partitionBananas();

        // - Burn (make sure sending to address 0 is possible)
        burn(banana, burnPart);

        // - Mint oBanana and burn (Locking them)
        uint oBananasToBurn = mintOBananas(lockPart);
        burn(oBananaMarket, oBananasToBurn);

        // - Send to Ola boss
        IERC20(banana).safeTransfer(olaBoss, olaPart);

        emit BananaDistributed(olaBoss, burnPart, lockPart, olaPart);
    }

    /**
     * Sends 10% of self balance in given token to the 'apeBoss' address
     * @param token The asset to send.
     */
    function sendAppBossPart(address token) internal returns (uint apeBossPart, uint reminder) {
        uint selfBalance = IERC20(token).balanceOf(address(this));
        apeBossPart = fractionFrom(selfBalance, tenPercent);
        reminder = selfBalance.sub(apeBossPart);

        IERC20(token).transfer(apeBoss, apeBossPart);
        emit ApeBossPartSent(apeBoss, token, apeBossPart);
    }

    /**
     * Burns the given amount out of own self balance.
     * @param token The asset to burn,
     * @param amount The amount to burn.
     */
    function burn(address token, uint amount) internal {
        IERC20(token).safeTransfer(burnAddress, amount);
    }

    /**
     * Mints oBanana by supplying the given amount of BANANA.
     */
    function mintOBananas(uint bananasToSupply) internal returns (uint oBananasMinted) {
        uint balanceBefore = IERC20(oBananaMarket).balanceOf(address(this));

        uint err = IOTokenForBananaMaker(oBananaMarket).mint(bananasToSupply);
        require(err == 0, "Error minting");

        uint balanceAfter = IERC20(oBananaMarket).balanceOf(address(this));

        oBananasMinted = balanceAfter.sub(balanceBefore);
    }

    /**
     *  Calculate the actual amount of banana for each purpose.
     */
    function partitionBananas() internal returns (uint burnPart, uint supplyAndBurnPart, uint olaPart) {
        uint bananaBalance = IERC20(banana).balanceOf(address(this));

        burnPart = fractionFrom(bananaBalance, thirtyPercent);
        supplyAndBurnPart = fractionFrom(bananaBalance, fiftyFivePercent);

        olaPart = bananaBalance.sub(burnPart).sub(supplyAndBurnPart);
    }

    /**
     * Wraps and available BNB (if there are any)
     */
    function wrapAllBNBInternal() internal returns (uint) {
        uint selfBnbBalance = address(this).balance;

        if (selfBnbBalance > 0) {
            IWBNBForBananaMaker(wBNB).deposit{value: selfBnbBalance}();
        }

        return selfBnbBalance;
    }

    /**
     * Calculate the part (fraction) out of the given amount.
     * @param amount The full amount (in any scale)
     * @param fraction A "decimal" fraction (e.g 0.23 = 23%) (scaled by 1e18)
     */
    function fractionFrom(uint amount, uint fraction) internal view returns (uint) {
        return amount.mul(fraction).div(fullUnit);
    }

    /**
     * It's not a fool proof solution, but it prevents flash loans, so here it's ok to use tx.origin
     */
    modifier onlyEOA() {
        // Try to make flash-loan exploit harder to do by only allowing externally owned addresses.
        require(msg.sender == tx.origin, "BananaMaker: must use EOA");
        _;
    }

    /**
     * Does nothing but wrap given BNB to wBNB to standardize the process.
     */
    receive() external payable {
        //  IWBNBForBananaMaker(wBNB).deposit{value:msg.value}();
    }
}

pragma solidity ^0.7.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// DAVID : remove in production version

interface IWETHForLiquidator {
    function withdraw(uint) external;
    function deposit() external payable;
}

interface CEthInterfaceForLiquidator {
    function liquidateBorrow(address borrower, address cTokenCollateral) external payable; // CToken instead of address
}

interface CErc20InterfaceForLiquidator {
    function liquidateBorrow(address borrower, uint amountToRepay, address cTokenCollateral) external returns (uint); // CTokenInterface instead of address
}

interface CTokenInterfaceForLiquidator {
    function redeem(uint redeemTokens) external returns (uint);
    function underlying() external view returns (address);
    function accrueInterest() external returns (uint);
    function borrowBalanceStored(address account) external view returns (uint);
    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);
    function getCash() external view returns (uint);
    function comptroller() external view returns (address); // DAVID : is this correct syntax ?
    function exchangeRateStored() external returns (uint);
}

contract LiquidatorBase {
    address public constant NATIVE = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    uint public constant fixedCloseFactor = 0.5e18;
    uint public constant expScale = 1e18;

    // TODO : CRITICAL : Add address
    address public WETH; // changes per chain WETH/WBNB/etc.

    constructor(address _wNative) {
        WETH = _wNative;
    }

    /**
     * @notice Using self capital
     */
    function liquidatePositionAndRedeemInternal(
        address cTokenBorrow,
        address borrower,
        uint repayAmount,
        address cTokenCollateral
    ) internal
    returns (uint cTokenCollateralAmountSeized)
    {
        cTokenCollateralAmountSeized = useSafeAmountAndLiquidatePosition(cTokenBorrow, borrower, repayAmount, cTokenCollateral);

        // TODO : make sure that redeeming cETH ends up in WETH due to receive()
        require(CTokenInterfaceForLiquidator(cTokenCollateral).redeem(cTokenCollateralAmountSeized) == 0, "redeem fail");
    }

    /**
     * Liquidates the position after ensuring self balance is sufficient
     */
    function useSafeAmountAndLiquidatePosition(
        address cTokenBorrow,
        address borrower,
        uint repayAmount,
        address cTokenCollateral
    ) internal returns (uint cTokenCollateralAmountSeized) {
        uint safeRepayAmount = getSafeRepayAmount(cTokenBorrow, cTokenCollateral, borrower, repayAmount);

        cTokenCollateralAmountSeized = liquidatePosition(cTokenBorrow, borrower, safeRepayAmount, cTokenCollateral, true);
    }

    /**
     * Does basic sanity and liquidates the position.
     * @param checkBalance Used to account for minor logical-flow inconsistencies regarding wNative
     */
    function liquidatePosition(address cTokenBorrow, address borrower, uint repayAmount, address cTokenCollateral, bool checkBalance) internal returns (uint cTokenCollateralAmountSeized) {
        address underlyingBorrow = CTokenInterfaceForLiquidator(cTokenBorrow).underlying();

        if (checkBalance) {
            // Safety -- Ensure contract has enough balance in borrowed asset
            uint borrowedAssetSelfBalance = _safeSelfBalanceOfUnderlying(underlyingBorrow);
            require(borrowedAssetSelfBalance >= repayAmount, "not enough to repay");
        }

        cTokenCollateralAmountSeized = liquidatePositionInternal(cTokenBorrow, underlyingBorrow, borrower, repayAmount, cTokenCollateral);
    }

    function liquidatePositionInternal(
        address cTokenBorrow,
        address underlyingBorrow,
        address borrower,
        uint amountToRepay,
        address cTokenCollateral
    )
    private
    returns (uint cTokenCollateralAmountSeized)
    {
        if (underlyingBorrow == NATIVE) {
            cTokenCollateralAmountSeized = _liquidatePositionEth(cTokenBorrow, borrower, amountToRepay, cTokenCollateral);
        } else {
            cTokenCollateralAmountSeized = _liquidatePositionErc(underlyingBorrow, cTokenBorrow, borrower, amountToRepay, cTokenCollateral);
        }
    }

    // **** Liquidation functions ****
    // **** Note : Both functions should work exactly the same (same sanity and logic, just erc20 vs native) ****

    function _liquidatePositionEth(
        address cTokenBorrow,
        address borrower,
        uint amountToRepay,
        address cTokenCollateral
    )
    internal
    returns (uint cTokenCollateralAmountSeized)
    {
        uint balanceCTokenCollateralBefore = IERC20(cTokenCollateral).balanceOf(address(this));

        // reverts if failure
        CEthInterfaceForLiquidator(cTokenBorrow).liquidateBorrow{value : amountToRepay}(borrower, cTokenCollateral);

        uint balanceCTokenCollateralAfter = IERC20(cTokenCollateral).balanceOf(address(this));
        require(balanceCTokenCollateralAfter > balanceCTokenCollateralBefore, "nothing seized native");
        uint cTokenGained = balanceCTokenCollateralAfter - balanceCTokenCollateralBefore;


        cTokenCollateralAmountSeized = cTokenGained;
    }

    function _liquidatePositionErc(
        address underlyingBorrow,
        address cTokenBorrow,
        address borrower,
        uint amountToRepay,
        address cTokenCollateral
    )
    internal
    returns (uint cTokenCollateralAmountSeized)
    {

        uint balanceCTokenCollateralBefore = IERC20(cTokenCollateral).balanceOf(address(this));

        if (IERC20(underlyingBorrow).allowance(address(this), cTokenBorrow) < amountToRepay) {
            // TODO : add max allowance (using safe approve)

            // Setting to 0 before setting to wanted amount
            IERC20(underlyingBorrow).approve(cTokenBorrow, 0);
            IERC20(underlyingBorrow).approve(cTokenBorrow, amountToRepay);
        }

        // TODO : Add previous balance

        require(CErc20InterfaceForLiquidator(cTokenBorrow).liquidateBorrow(borrower, amountToRepay, cTokenCollateral) == 0, "liquidation fail");

        uint balanceCTokenCollateralAfter = IERC20(cTokenCollateral).balanceOf(address(this));
        require(balanceCTokenCollateralAfter > balanceCTokenCollateralBefore, "nothing seized erc");
        uint cTokenGained = balanceCTokenCollateralAfter - balanceCTokenCollateralBefore;


        cTokenCollateralAmountSeized = cTokenGained;
    }

    // **** Calculations utils ****

    function getSafeRepayAmount(address cTokenBorrow, address cTokenCollateral, address borrower, uint repayAmount) internal returns (uint) {
        require(CTokenInterfaceForLiquidator(cTokenBorrow).accrueInterest() == 0, "borrow accrue");

        // TODO : Using 'cToken.borrowBalanceCurrent' will retrieve the 'borrowBalanceStored' after accruing interest
        if (cTokenBorrow != cTokenCollateral) {
            require(CTokenInterfaceForLiquidator(cTokenCollateral).accrueInterest() == 0, "collateral accrue");
        }

        uint totalBorrow = CTokenInterfaceForLiquidator(cTokenBorrow).borrowBalanceStored(borrower);

        // TODO : CRITICAL : SafeMath
        uint maxClose = (fixedCloseFactor * totalBorrow) / expScale;

        // amountOut desired from swap
        if (repayAmount == 0) {
            // Removing a bit of dust to avoid rounding errors
            repayAmount = maxClose - 1e1;
        } else {
            require(repayAmount <= maxClose, "repayAmount too big");
        }

        return repayAmount;
    }

    function _safeSelfBalanceOfUnderlying(address token) internal returns (uint balance) {
        if (token == NATIVE) {
            // NOTE : self balance caused problems in the past
            balance = address(this).balance;
        } else {
            balance = IERC20(token).balanceOf(address(this));
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.7/interfaces/AggregatorV3Interface.sol";
import "../interfaces/IPriceOracle.sol";
import "./LPMath.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";



interface MinistryForLPPriceOracle {
    function getPriceForAsset(address asset) external view returns (uint256);
}

interface UniswapV2PairForLPPriceOracle {
    function totalSupply() external view returns (uint);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );
}

/**
 * @title Ola's ChainLink based price oracle.
 * @author Ola
 */
contract LPPriceOracle is IPriceOracle, Ownable {
    using SafeMath for uint;
    using LPMath for uint;

    // LP -> is supported
    mapping(address => bool) public supportedLPs;

    event NewLPTokenSupported(address indexed asset);

    address public ministry;

    constructor (address _ministry) {
        ministry = _ministry;
    }

    /**
     * @notice Get the price an asset
     * @param asset The asset to get the price of
     * @return The asset price mantissa (scaled by 1e(36 - assetDecimals))
     *  Zero means the price is unavailable.
     */
    function getAssetPrice(address asset) external override view returns (uint) {
        return _getPriceForAssetInternal(asset);
    }

    /**
     * @notice Get the price update timestamp for the asset
     * @param asset The asset address for price update timestamp retrieval.
     * @return Last price update timestamp for the asset
     */
    function getAssetPriceUpdateTimestamp(address asset) external override view returns (uint) {
        return _getPriceUpdateTimestampForAssetInternal(asset);
    }

    /**
      * @notice Get the underlying price of a cToken asset
      * @param cToken The cToken to get the underlying price of
      * @return The underlying asset price mantissa (scaled by 1e(36 - assetDecimals)).
      *  Zero means the price is unavailable.
      */
    function getUnderlyingPrice(address cToken) external override view returns (uint) {
        return _getPriceForAssetInternal(ICTokenForPriceOracle(cToken).underlying());
    }

    /**
     * @notice Get the price update timestamp for the cToken underlying
     * @param cToken The cToken address for price update timestamp retrieval.
     * @return Last price update timestamp for the cToken underlying asset
     */
    function getUnderlyingPriceUpdateTimestamp(address cToken) external override view returns (uint) {
        return _getPriceUpdateTimestampForAssetInternal(ICTokenForPriceOracle(cToken).underlying());
    }

    function _setPriceFeedForUnderlying(address _underlying) onlyOwner external {
        _setPriceFeedForUnderlyingInternal(_underlying);
    }

    function _setPriceFeedsForUnderlyings(address[] calldata _underlyings) onlyOwner external {
        for (uint i = 0; i < _underlyings.length; i++) {
            _setPriceFeedForUnderlyingInternal(_underlyings[i]);
        }
    }

    function getPriceForAsset(address asset) public view returns (uint) {
        return _getPriceForAssetInternal(asset);
    }

    function hasFeedForAsset(address asset) public view returns (bool) {
        return supportedLPs[asset];
    }

    function isPriceOracle() public override pure returns (bool) {
        return true;
    }

    function _setPriceFeedForUnderlyingInternal(address underlying) internal {
        require(!supportedLPs[underlying], "LP already supported");

        supportedLPs[underlying] = true;

        emit NewLPTokenSupported(underlying);
    }

    /**
      * @notice Get the underlying price of a cToken asset
      * @param asset The asset (Erc20 or native)
      * @return The asset price mantissa (scaled by 1e(36 - assetDecimals)).
      *  Zero means the price is unavailable.
      */
    function _getPriceForAssetInternal(address asset) internal view returns (uint) {
        if (hasFeedForAsset(asset)) {
            uint priceRaw = _calculateLPFairPrice(asset);

            return priceRaw.mul(10 ** 18).div(2 ** 112);
        } else {
            return 0;
        }
    }

    function _getPriceUpdateTimestampForAssetInternal(address asset) internal view returns (uint) {
        // TODO : DES : Add logic
        return 0;
    }

    function _calculateLPFairPrice(address lpToken) internal view returns (uint) {
        uint token0Price = MinistryForLPPriceOracle(ministry).getPriceForAsset(UniswapV2PairForLPPriceOracle(lpToken).token0());
        uint token1Price = MinistryForLPPriceOracle(ministry).getPriceForAsset(UniswapV2PairForLPPriceOracle(lpToken).token1());

        uint px0 = token0Price.mul(2*112).div(10**18);
        uint px1 = token1Price.mul(2*112).div(10**18);

        uint totalSupply = UniswapV2PairForLPPriceOracle(lpToken).totalSupply();

        (uint r0, uint r1, ) = UniswapV2PairForLPPriceOracle(lpToken).getReserves();

        uint sqrtK = LPMath.sqrt(r0.mul(r1)).fdiv(totalSupply); // in 2 **112

        // fair token0 amt: sqrtK * sqrt(px1/px0)
        // fair token1 amt: sqrtK * sqrt(px0/px1)
        // fair lp price = 2 * sqrt(px0 * px1)
        // split into 2 sqrts multiplication to prevent uint overflow (note the 2**112)
        uint fairPrice = sqrtK.mul(2).mul(LPMath.sqrt(px0)).div(2**56).mul(LPMath.sqrt(px1)).div(2**56);

        return fairPrice;
    }

    /// @dev Overflow proof multiplication
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) return 0;
        uint c = a * b;
        require(c / a == b, "multiplication overflow");
        return c;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import "@openzeppelin/contracts/math/SafeMath.sol";

library LPMath {
    using SafeMath for uint;

    function divCeil(uint lhs, uint rhs) internal pure returns (uint) {
        return lhs.add(rhs).sub(1) / rhs;
    }

    function fmul(uint lhs, uint rhs) internal pure returns (uint) {
        return lhs.mul(rhs) / (2**112);
    }

    function fdiv(uint lhs, uint rhs) internal pure returns (uint) {
        return lhs.mul(2**112) / rhs;
    }

    // implementation from https://github.com/Uniswap/uniswap-lib/commit/99f3f28770640ba1bb1ff460ac7c5292fb8291a0
    // original implementation: https://github.com/abdk-consulting/abdk-libraries-solidity/blob/master/ABDKMath64x64.sol#L687
    function sqrt(uint x) internal pure returns (uint) {
        if (x == 0) return 0;
        uint xx = x;
        uint r = 1;

        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }

        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }

        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint r1 = x / r;
        return (r < r1 ? r : r1);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.7/interfaces/AggregatorV3Interface.sol";
import "../interfaces/IPriceOracle.sol";

/**
 * @title Ola's ChainLink based price oracle.
 * @author Ola
 */
contract ChainlinkPriceOracle is IPriceOracle, Ownable {


    // Underlying -> ChainLink Feed address
    mapping(address => address) public chainLinkFeeds;

    // Underlying -> ChainLink Feed decimals
    mapping(address => uint8) public chainLinkFeedDecimals;

    // Underlying -> assets decimals
    mapping(address => uint8) public assetsDecimals;

    event NewFeedForAsset(address indexed asset, address oldFeed, address newFeed);
    event NewFeedDecimalsForAsset(address indexed asset, uint8 oldFeedDecimals, uint8 newFeedDecimals);


    /**
     * @notice Get the price an asset
     * @param asset The asset to get the price of
     * @return The asset price mantissa (scaled by 1e(36 - assetDecimals)).
     *  Zero means the price is unavailable.
     */
    function getAssetPrice(address asset) external override view returns (uint) {
        return _getPriceForAssetInternal(asset);
    }

    /**
     * @notice Get the price update timestamp for the asset
     * @param asset The asset address for price update timestamp retrieval.
     * @return Last price update timestamp for the asset
     */
    function getAssetPriceUpdateTimestamp(address asset) external override view returns (uint) {
        return _getPriceUpdateTimestampForAssetInternal(asset);
    }

    /**
      * @notice Get the underlying price of a cToken asset
      * @param cToken The cToken to get the underlying price of
      * @return The underlying asset price mantissa (scaled by 1e(36 - assetDecimals)).
      *  Zero means the price is unavailable.
      */
    function getUnderlyingPrice(address cToken) external override view returns (uint) {
        return _getPriceForAssetInternal(ICTokenForPriceOracle(cToken).underlying());
    }

    /**
     * @notice Get the price update timestamp for the cToken underlying
     * @param cToken The cToken address for price update timestamp retrieval.
     * @return Last price update timestamp for the cToken underlying asset
     */
    function getUnderlyingPriceUpdateTimestamp(address cToken) external override view returns (uint) {
        return _getPriceUpdateTimestampForAssetInternal(ICTokenForPriceOracle(cToken).underlying());
    }

    function _setPriceFeedForUnderlying(address _underlying, address _chainlinkFeed, uint8 _priceFeedDecimals) onlyOwner external {
        _setPriceFeedForUnderlyingInternal(_underlying, _chainlinkFeed, _priceFeedDecimals);
    }

    function _setPriceFeedsForUnderlyings(address[] calldata _underlyings, address[] calldata _chainlinkFeeds, uint8[] calldata _priceFeedsDecimals) onlyOwner external {
        require(_underlyings.length == _chainlinkFeeds.length, "underlyings and chainlinkFeeds should be 1:1");
        require(_underlyings.length == _priceFeedsDecimals.length, "underlyings and priceFeedsDecimals should be 1:1");

        for (uint i = 0; i < _underlyings.length; i++) {
            _setPriceFeedForUnderlyingInternal(_underlyings[i], _chainlinkFeeds[i], _priceFeedsDecimals[i]);
        }
    }

    function getPriceForAsset(address asset) public view returns (uint) {
        return _getPriceForAssetInternal(asset);
    }

    function hasFeedForAsset(address asset) public view returns (bool) {
        return chainLinkFeeds[asset] != address(0);
    }

    function chainLinkRawReportedPrice(address asset) public view returns (int) {
        return getChainLinkPrice(AggregatorV3Interface(chainLinkFeeds[asset]));
    }

    function isPriceOracle() public override pure returns (bool) {
        return true;
    }


    function _setPriceFeedForUnderlyingInternal(address underlying, address chainlinkFeed, uint8 priceFeedDecimals) internal {
        address existingFeed = chainLinkFeeds[underlying];
        uint8 existingDecimals = chainLinkFeedDecimals[underlying];

        require(existingFeed == address(0), "Cannot reassign feed");

        uint8 decimalsForAsset;

        if (underlying == address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)) {
            decimalsForAsset = 18;
        } else {
            decimalsForAsset = ERC20(underlying).decimals();
        }

        // Update if the feed is different
        if (existingFeed != chainlinkFeed) {
            chainLinkFeeds[underlying] = chainlinkFeed;
            chainLinkFeedDecimals[underlying] = priceFeedDecimals;
            assetsDecimals[underlying] = decimalsForAsset;
            emit NewFeedForAsset(underlying, existingFeed, chainlinkFeed);
            emit NewFeedDecimalsForAsset(underlying, existingDecimals, priceFeedDecimals);
        }
    }

    /**
      * @notice Get the underlying price of a cToken asset
      * @param asset The asset (Erc20 or native)
      * @return The asset price mantissa (scaled by 1e(36 - assetDecimals)).
      *  Zero means the price is unavailable.
      */
    function _getPriceForAssetInternal(address asset) internal view returns (uint) {
        if (hasFeedForAsset(asset)) {
            uint8 feedDecimals = chainLinkFeedDecimals[asset];
            uint8 assetDecimals = assetsDecimals[asset];
            address feed = chainLinkFeeds[asset];
            int feedPriceRaw = getChainLinkPrice(AggregatorV3Interface(feed));
            uint feedPrice = uint(feedPriceRaw);

            // Safety
            require(feedPriceRaw == int(feedPrice), "Price Conversion error");

            // Needs to be scaled to e36 and then divided by the asset's decimals
            if (feedDecimals == 8) {
                return (mul(1e28, feedPrice) / (10 ** assetDecimals));
            } else if (feedDecimals == 18) {
                return (mul(1e18, feedPrice) / (10 ** assetDecimals));
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    }

    function _getPriceUpdateTimestampForAssetInternal(address asset) internal view returns (uint) {
        if (hasFeedForAsset(asset)) {
            return getChainLinkUpdateTimestamp(AggregatorV3Interface(chainLinkFeeds[asset]));
        } else {
            return 0;
        }
    }

    function getChainLinkPrice(AggregatorV3Interface priceFeed) internal view returns (int) {
        (
        uint80 roundID,
        int price,
        uint startedAt,
        uint timeStamp,
        uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }

    function getChainLinkUpdateTimestamp(AggregatorV3Interface priceFeed) internal view returns (uint) {
        (
        uint80 roundID,
        int price,
        uint startedAt,
        uint timeStamp,
        uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return timeStamp;
    }

    /// @dev Overflow proof multiplication
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) return 0;
        uint c = a * b;
        require(c / a == b, "multiplication overflow");
        return c;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/IPriceOracle.sol";


/**
 * @title Ola's Fixed price(s) oracle.
 * @author Ola
 */
contract FixedPriceOracle is IPriceOracle, Ownable {

    bytes32 constant public emptySymbolHash = keccak256("");

    // Asset address -> Fixed price for asset
    // Prices should be scaled by 10^6
    mapping(address => uint) public prices;

    // Underlying -> assets decimals
    mapping(address => uint8) public assetsDecimals;

    event NewFixedPriceForAsset(address indexed asset, uint price);

    constructor() {}

    //// **** INTERFACE FUNCTIONS ****

    /**
     * Sanity flag
     */
    function isPriceOracle() public override pure returns (bool) {
        return true;
    }

    /**
     * @notice Get the price an asset
     * @param asset The asset to get the price of
     * @return The asset price mantissa (scaled by 1e(36 - assetDecimals))
     *  Zero means the price is unavailable.
     */
    function getAssetPrice(address asset) external override view returns (uint) {
        return _getPriceForAssetInternal(asset);
    }

    /**
     * OLA_ADDITIONS : This function
     * @notice Get the price update timestamp for the asset
     * @param asset The asset address for price update timestamp retrieval.
     * @return Last price update timestamp for the asset
     */
    function getAssetPriceUpdateTimestamp(address asset) external override view returns (uint) {
        return _getPriceUpdateTimestampForAssetInternal(asset);
    }

    /**
      * @notice Get the underlying price of a cToken asset
      * @param cToken The cToken to get the underlying price of
      * @return The underlying asset price mantissa (scaled by 1e(36 - assetDecimals)).
      *  Zero means the price is unavailable.
      */
    function getUnderlyingPrice(address cToken) external override view returns (uint) {
        return _getPriceForAssetInternal(ICTokenForPriceOracle(cToken).underlying());
    }

    /**
     * @notice Get the price update timestamp for the cToken underlying
     * @param cToken The cToken address for price update timestamp retrieval.
     * @return Last price update timestamp for the cToken underlying asset
     */
    function getUnderlyingPriceUpdateTimestamp(address cToken) external override view returns (uint) {
        return _getPriceUpdateTimestampForAssetInternal(ICTokenForPriceOracle(cToken).underlying());
    }

    //// **** INTERFACE FUNCTIONS - END ****

    /**
     * Sets the fixed price for the given undedrlying.
     * Price should be scaled by 10^6
     */
    function _setFixedPriceForUnderlying(address _underlying, uint _price) onlyOwner external {
        _setFixedPriceForUnderlyingInternal(_underlying, _price);
    }

    /**
     * Sets the fixed prices for the given undedrlyings.
     * Prices should be scaled by 10^6
     */
    function _setFixedPricesForUnderlyings(address[] calldata _underlyings, uint[] calldata _prices) onlyOwner external {
        require(_underlyings.length == _prices.length, "underlyings and prices should be 1:1");

        for (uint i = 0; i < _underlyings.length; i++) {
            _setFixedPriceForUnderlyingInternal(_underlyings[i], _prices[i]);
        }
    }

    function getPriceForAsset(address asset) public view returns (uint) {
        return _getPriceForAssetInternal(asset);
    }

    function _setFixedPriceForUnderlyingInternal(address underlying, uint price) internal {
        uint existingPrice = prices[underlying];

        require(existingPrice == 0, "Cannot reassign price");

        uint8 decimalsForAsset;

        if (underlying == address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)) {
            decimalsForAsset = 18;
        } else {
            decimalsForAsset = ERC20(underlying).decimals();
        }

        prices[underlying] = price;
        assetsDecimals[underlying] = decimalsForAsset;
        emit NewFixedPriceForAsset(underlying, price);
    }

    /**
      * @notice Get the underlying price of a cToken asset
      * @param asset The asset (Erc20 or native)
      * @return The asset price mantissa (scaled by 1e(36 - assetDecimals)).
      *  Zero means the price is unavailable.
      */
    function _getPriceForAssetInternal(address asset) internal view returns (uint) {
        uint storedFixedPrice = prices[asset];
        uint8 assetDecimals = assetsDecimals[asset];

        if (storedFixedPrice == 0) {
            return 0;
        } else {
            // All fixed prices are scaled by 1e6
            return (mul(1e30, storedFixedPrice) / (10 ** assetDecimals));
        }
    }

    /**
     * @notice Price will never change
     */
    function _getPriceUpdateTimestampForAssetInternal(address asset) internal view returns (uint) {
        return 0;
    }

    /// @dev Overflow proof multiplication
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) return 0;
        uint c = a * b;
        require(c / a == b, "multiplication overflow");
        return c;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/IPriceOracle.sol";

abstract contract BasePriceOracle is IPriceOracle, Ownable {

    event NewDecimalsConfiguredForAsset(address indexed asset, uint decimals);

    // Underlying -> assets decimals
    mapping(address => uint8) public assetsDecimals;

    // ******************
    // IPriceOracle Functions
    // ******************

    /**
     * @notice Get the price an asset
     * @param asset The asset to get the price of
     * @return The asset price mantissa (scaled by 1e(36 - assetDecimals)).
     *  Zero means the price is unavailable.
     */
    function getAssetPrice(address asset) external override view returns (uint) {
        return _getPriceForAssetInternalIfSupported(asset);
    }

    /**
     * @notice Get the price update timestamp for the asset
     * @param asset The asset address for price update timestamp retrieval.
     * @return Last price update timestamp for the asset
     */
    function getAssetPriceUpdateTimestamp(address asset) external override view returns (uint) {
        return _getPriceUpdateTimestampForAssetIfSupported(asset);
    }

    /**
      * @notice Get the underlying price of a cToken asset
      * @param cToken The cToken to get the underlying price of
      * @return The underlying asset price mantissa (scaled by 1e(36 - underlyingDecimals)).
      *  Zero means the price is unavailable.
      */
    function getUnderlyingPrice(address cToken) external override view returns (uint) {
        return _getPriceForAssetInternalIfSupported(ICTokenForPriceOracle(cToken).underlying());
    }

    /**
     * @notice Get the price update timestamp for the cToken underlying
     * @param cToken The cToken address for price update timestamp retrieval.
     * @return Last price update timestamp for the cToken underlying asset
     */
    function getUnderlyingPriceUpdateTimestamp(address cToken) external override view returns (uint) {
        return _getPriceUpdateTimestampForAssetIfSupported(ICTokenForPriceOracle(cToken).underlying());
    }

    function isPriceOracle() public override pure returns (bool) {
        return true;
    }

    // ******************
    // Public virtual Functions
    // ******************

    function isAssetSupported(address asset) public view virtual returns (bool) {
        uint8 decimals = assetsDecimals[asset];
        return decimals != 0;
    }

    // ******************
    // Internal Functions
    // ******************

    /**
     * @notice Get the underlying price of an asset
     * @param asset The asset (Erc20 or native)
     * @return The asset price mantissa (scaled by 1e(36 - assetDecimals)).
     *  Zero means the price is unavailable.
     */
    function _getPriceForAssetInternalIfSupported(address asset) internal view returns (uint) {
        if (isAssetSupported(asset)) {
            return getPriceFromSourceInternal(asset);
        } else {
            return 0;
        }
    }

    /**
     * @notice Get the underlying price update timestamp of an asset
     * @param asset The asset (Erc20 or native)
     * @return The asset update timestamp.
     *  Zero means the price update timestamp is unavailable.
     */
    function _getPriceUpdateTimestampForAssetIfSupported(address asset) internal view returns (uint) {
        if (isAssetSupported(asset)) {
            return getPriceUpdateTimestampFromSourceInternal(asset);
        } else {
            return 0;
        }
    }

    /**
     * @notice saves to storage the decimals for the given asset.
     * This is done to reduce future calls gas cost.
     */
    function _setDecimalsForAsset(address _asset) internal {
        uint8 decimalsForAsset;

        if (_asset == address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)) {
            decimalsForAsset = 18;
        } else {
            decimalsForAsset = ERC20(_asset).decimals();
        }

        assetsDecimals[_asset] = decimalsForAsset;

        emit NewDecimalsConfiguredForAsset(_asset, decimalsForAsset);
    }

    // ******************
    // Internal virtual Functions
    // ******************

//    /**
//     * @notice Should return true if the given asset is supported by the oracle.
//     * @param asset The asset.
//     */
//    function isAssetSupported(address asset) internal view virtual returns (bool);

    /**
     * @notice This function should be implemented to retrieve the price for the asset in question.
     * @param asset The asset in question.
     */
    function getPriceFromSourceInternal(address asset) internal view virtual returns (uint);

    /**
     * @notice This function should be implemented to retrieve the price update timestamp for the asset in question.
     * @param asset The asset in question.
     */
    function getPriceUpdateTimestampFromSourceInternal(address asset) internal view virtual returns (uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "../interfaces/IPriceOracle.sol";
import "../BasePriceOracle/BasePriceOracle.sol";

/**
* Based on https://docs.diadata.org/documentation/oracle-documentation/access-the-oracle#dia-key-value-oracle-contract-v2
*/
interface DiaOracleV2ForOracle {
    // returns (value, timestamp)
    function getValue(string memory key) external view returns (uint128, uint128);
}

/**
 * @title Ola's Witnet router based price oracle.
 * @author Ola
 */
contract DiaV2PriceOracle is BasePriceOracle {

    // The BAND protocol price source
    DiaOracleV2ForOracle public diaOracleV2;

    // Asset address -> matching key for the DIA V2 key-value protocol
    mapping(address => string) public assetsOracleKeys;

    event NewKeyConfiguredForAsset(address indexed asset, string indexed diaV2Key);

    constructor(address _diaOracleV2) {
        diaOracleV2 = DiaOracleV2ForOracle(_diaOracleV2);
    }

    function _setAssetKeyForUnderlying(address _underlying, string calldata diaV2Key) onlyOwner external {
        _setPriceFeedForUnderlyingInternal(_underlying, diaV2Key);
    }

    function _setAssetKeysForUnderlyings(address[] calldata _underlyings, string[] calldata _diaV2Keys) onlyOwner external {
        require(_underlyings.length == _diaV2Keys.length, "underlyings and keys should be 1:1");

        for (uint i = 0; i < _underlyings.length; i++) {
            _setPriceFeedForUnderlyingInternal(_underlyings[i], _diaV2Keys[i]);
        }
    }

    function _setPriceFeedForUnderlyingInternal(address _underlying, string memory _diaV2Key) internal {
        require(!isAssetSupported(_underlying), "Cannot reassign symbol");

        // BasePriceOracle
        _setDecimalsForAsset(_underlying);

        // DiaV2
        assetsOracleKeys[_underlying] = _diaV2Key;
        emit NewKeyConfiguredForAsset(_underlying, _diaV2Key);
    }

    /**
      * @notice Get the underlying price of a cToken asset
      * @param asset The asset (Erc20 or native)
      * @return The asset price mantissa (scaled by 1e(36 - assetDecimals)).
      *  Zero means the price is unavailable.
      */
    function getPriceFromSourceInternal(address asset) internal view override returns (uint) {
        uint8 assetDecimals = assetsDecimals[asset];
        string memory oracleKey = assetsOracleKeys[asset];

        int feedPriceRaw = getDiaV2Price(oracleKey);
        uint oraclePrice = uint(feedPriceRaw);

        // Sanity
        require(feedPriceRaw == uint128(oraclePrice), "Price Conversion error");

        // Needs to be scaled to e36 and then divided by the asset's decimals
        return (mul(1e28, oraclePrice) / (10 ** assetDecimals));
    }

    function getPriceUpdateTimestampFromSourceInternal(address asset) internal view override returns (uint) {
        string memory oracleKey = assetsOracleKeys[asset];

        int timestampRaw = getDiaV2UpdateTimestamp(oracleKey);

        return uint(timestampRaw);
    }

    function getDiaV2Price(string memory key) internal view returns (uint128 value) {
        (value, ) = getDiaV2KeyValueOracleResponse(key);
    }

    function getDiaV2UpdateTimestamp(string memory key) internal view returns (uint128) {
        uint128 updateTimestamp;
        (, updateTimestamp) = getDiaV2KeyValueOracleResponse(key);
        return updateTimestamp;
    }

    function getDiaV2KeyValueOracleResponse(string memory key) internal view returns(uint128 value, uint128 timestamp) {
        (value, timestamp) = diaOracleV2.getValue(key);
    }

    /// @dev Overflow proof multiplication
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) return 0;
        uint c = a * b;
        require(c / a == b, "multiplication overflow");
        return c;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/IPriceOracle.sol";

/**
 * BAND protocol interface
 * https://docs.bandchain.org/band-standard-dataset/using-band-dataset/using-band-dataset-evm.html
 */
interface IStdReference {
    /// A structure returned whenever someone requests for standard reference data.
    struct ReferenceData {
        uint256 rate; // base/quote exchange rate, multiplied by 1e18.
        uint256 lastUpdatedBase; // UNIX epoch of the last time when base price gets updated.
        uint256 lastUpdatedQuote; // UNIX epoch of the last time when quote price gets updated.
    }

    /// Returns the price data for the given base/quote pair. Revert if not available.
    function getReferenceData(string memory _base, string memory _quote)
    external
    view
    returns (ReferenceData memory);

    /// Similar to getReferenceData, but with multiple base/quote pairs at once.
    function getReferenceDataBulk(string[] memory _bases, string[] memory _quotes)
    external
    view
    returns (ReferenceData[] memory);
}

/**
 * @title Ola's Band based price oracle.
 * @author Ola
 */
contract BandPriceOracle is IPriceOracle, Ownable {

    bytes32 constant public emptySymbolHash = keccak256("");

    // All prices are measured against the USD
    string constant public dollarQuoteSymbol = "USD";

    // All BAND prices are given with 18 decimals of precision
    uint8 constant public quoteDecimals = 18;

    // The BAND protocol price source
    IStdReference immutable public stdReferenceContract;

    // Asset address -> matching symbol for the BAND protocol
    mapping(address => string) public assetsSymbols;

    // Underlying -> assets decimals
    mapping(address => uint8) public assetsDecimals;

    event NewSymbolForAsset(address indexed asset, string oldSymbol, string newSymbol);

    constructor(address _stdReferenceContract) {
        stdReferenceContract = IStdReference(_stdReferenceContract);
    }

    /**
     * @notice Get the price an asset
     * @param asset The asset to get the price of
     * @return The asset price mantissa (scaled by 1e(36 - assetDecimals)).
     *  Zero means the price is unavailable.
     */
    function getAssetPrice(address asset) external override view returns (uint) {
        return _getPriceForAssetInternal(asset);
    }

    /**
     * OLA_ADDITIONS : This function
     * @notice Get the price update timestamp for the asset
     * @param asset The asset address for price update timestamp retrieval.
     * @return Last price update timestamp for the asset
     */
    function getAssetPriceUpdateTimestamp(address asset) external override view returns (uint) {
        return _getPriceUpdateTimestampForAssetInternal(asset);
    }

    /**
      * @notice Get the underlying price of a cToken asset
      * @param cToken The cToken to get the underlying price of
      * @return The underlying asset price mantissa (scaled by 1e(36 - underlyingDecimals)).
      *  Zero means the price is unavailable.
      */
    function getUnderlyingPrice(address cToken) external override view returns (uint) {
        return _getPriceForAssetInternal(ICTokenForPriceOracle(cToken).underlying());
    }

    /**
     * @notice Get the price update timestamp for the cToken underlying
     * @param cToken The cToken address for price update timestamp retrieval.
     * @return Last price update timestamp for the cToken underlying asset
     */
    function getUnderlyingPriceUpdateTimestamp(address cToken) external override view returns (uint) {
        return _getPriceUpdateTimestampForAssetInternal(ICTokenForPriceOracle(cToken).underlying());
    }

    function _setAssetSymbolForUnderlying(address _underlying, string calldata _symbol) onlyOwner external {
        _setAssetSymbolsForUnderlyingInternal(_underlying, _symbol);
    }

    function _setAssetSymbolsForUnderlyings(address[] calldata _underlyings, string[] calldata _symbols) onlyOwner external {
        require(_underlyings.length == _symbols.length, "underlyings and symbols should be 1:1");

        for (uint i = 0; i < _underlyings.length; i++) {
            _setAssetSymbolsForUnderlyingInternal(_underlyings[i], _symbols[i]);
        }
    }

    function getPriceForAsset(address asset) public view returns (uint) {
        return _getPriceForAssetInternal(asset);
    }

    function hasSymbolForAsset(address asset) public view returns (bool) {
        return keccak256(abi.encodePacked(assetsSymbols[asset])) != emptySymbolHash;
    }

    function isPriceOracle() public override pure returns (bool) {
        return true;
    }

    function _setAssetSymbolsForUnderlyingInternal(address underlying, string calldata assetSymbol) internal {
        string storage existingSymbol = assetsSymbols[underlying];

        require(!hasSymbolForAsset(underlying), "Cannot reassign symbol");

        uint8 decimalsForAsset;

        if (underlying == address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)) {
            decimalsForAsset = 18;
        } else {
            decimalsForAsset = ERC20(underlying).decimals();
        }

        assetsSymbols[underlying] = assetSymbol;
        assetsDecimals[underlying] = decimalsForAsset;
        emit NewSymbolForAsset(underlying, existingSymbol, assetSymbol);
    }

    /**
      * @notice Get the underlying price of a cToken asset
      * @param asset The asset (Erc20 or native)
      * @return The asset price mantissa (scaled by 1e(36 - assetDecimals)).
      *  Zero means the price is unavailable.
      */
    function _getPriceForAssetInternal(address asset) internal view returns (uint) {
        if (hasSymbolForAsset(asset)) {
            string storage assetSymbol = assetsSymbols[asset];
            uint8 assetDecimals = assetsDecimals[asset];

            uint bandPrice = getBandPrice(assetSymbol);

            // Needs to be scaled to e36 and then divided by the asset's decimals
            // All band prices are scaled by 1e18
            return (mul(1e18, bandPrice) / (10 ** assetDecimals));
        } else {
            return 0;
        }
    }

    function _getPriceUpdateTimestampForAssetInternal(address asset) internal view returns (uint) {
        if (hasSymbolForAsset(asset)) {
            return getBandUpdateTimestamp(assetsSymbols[asset]);
        } else {
            return 0;
        }
    }

    function getBandPrice(string storage symbol) internal view returns (uint) {
        IStdReference.ReferenceData memory referenceData = stdReferenceContract.getReferenceData(symbol, dollarQuoteSymbol);

        return referenceData.rate;
    }

    function getBandUpdateTimestamp(string storage symbol) internal view returns (uint) {
        IStdReference.ReferenceData memory referenceData = stdReferenceContract.getReferenceData(symbol, dollarQuoteSymbol);

        // Quote is always in USD, so we will use the base update timestamp
        return referenceData.lastUpdatedBase;
    }

    /// @dev Overflow proof multiplication
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) return 0;
        uint c = a * b;
        require(c / a == b, "multiplication overflow");
        return c;
    }
}

pragma solidity ^0.7.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IGaugesInteractor.sol";

// TODO : think about sanity checks ?
contract SingleGaugeInteractor is Ownable, IGaugesInteractor {

    IGaugeForInteractor gauge;
    ERC20 gaugeToken;
    ERC20 distributionToken;

    constructor (address _gauge, address _gaugeToken, address _distributionToken) {
        gauge = IGaugeForInteractor(_gauge);
        gaugeToken = ERC20(_gaugeToken);
        distributionToken = ERC20(_distributionToken);

        // Only needed to be called once
        gaugeToken.approve(address(gauge), uint(-1));
    }


    // *** Gauge Interaction ***
    function depositToGauge(uint amount) onlyOwner override external {
        gauge.deposit(amount);
    }

    function depositAllToGauge() onlyOwner override external {
        gauge.depositAll();
    }

    function withdrawFromGauge(uint amount) onlyOwner override external {
        gauge.withdraw(amount);
    }

    function withdrawAllFromGauge() onlyOwner override external {
        gauge.withdrawAll();
    }

    // *** Distribution ***

    function claimRewardsFromGauge() onlyOwner override external {
        claimRewardsFromGaugeInternal();
    }

    // *** Admin Accounting ***
    function sweepToken(address token) onlyOwner override external {
        sweepTokenInternal(ERC20(token));
    }

    function sweepTokenByAmount(address token, uint amount) onlyOwner override external {
        ERC20(token).transfer(owner(), amount);
    }

    /**
     * Pulls out of the gauge and transfer the gauge token and any distribution received.
     */
    function closingTime() onlyOwner external {
        claimRewardsFromGaugeInternal();
        sweepTokenInternal(gaugeToken);
        sweepTokenInternal(distributionToken);
    }


    // *** Internal implementation ***
    function claimRewardsFromGaugeInternal() internal {
        gauge.getReward();
    }

    function sweepTokenInternal(ERC20 token) internal {
        token.transfer(owner(), token.balanceOf(address(this)));
    }
}

pragma solidity ^0.7.6;

interface IGaugesInteractor {
    function depositToGauge(uint amount) external;
    function depositAllToGauge() external;
    function withdrawFromGauge(uint amount) external;
    function withdrawAllFromGauge() external;
    function claimRewardsFromGauge() external;

    // Admin accounting
    function sweepToken(address token) external;
    function sweepTokenByAmount(address token, uint amount) external;
}

/**
 * All needed functions from a gauge
 */
interface IGaugeForInteractor {
    function depositAll() external;
    function deposit(uint256 amount) external;
    function withdrawAll() external;
    function withdraw(uint256 amount) external;

    /**
     * Should get all rewards (after fresh distribution)
     */
    function getReward() external;
}

pragma solidity ^0.7.6;

import "./CloudsMakerInterface.sol";
import "../Interactors/GaugesInteractor/SingleGaugeInteractor.sol";

contract GaugeCloudMaker is SingleGaugeInteractor, CloudsMakerInterface {
    address public unitroller;
    address public targetRainMaker;

    event ApprovedCallerAdded(address indexed account);
    event ApprovedCallerRemoved(address indexed account);

    // Account - can call 'condenseAndDispense'
    mapping(address => bool) approvedCallers;


    constructor(address _unitroller, address _gauge, address _gaugeToken, address _distributionToken) SingleGaugeInteractor(_gauge, _gaugeToken, _distributionToken) {
        unitroller = _unitroller;
        reSyncTargetRainMakerInternal();
    }

    // **** Cloud Maker Interface ****

    function condenseAndDispense() override external returns (uint dispensedTokens) {
        // Safety
        require(msg.sender == owner() || approvedCallers[msg.sender], "Only owner or approved callers");
        require(targetRainMaker != address(0), "No target");

        // Condense
        claimRewardsFromGaugeInternal();

        // Dispense
        return transferAllDistributionBalanceToTarget();
    }


    // **** Admin Accounting ****

    function reSyncTargetRainMaker() external onlyOwner {
        reSyncTargetRainMakerInternal();
    }

    // **** Admin Setters ****
    function approveCaller(address account) external onlyOwner {
        if (!approvedCallers[account]) {
            approvedCallers[account] = true;
            emit ApprovedCallerAdded(account);
        }
    }

    function removeCallerPermission(address account) external onlyOwner {
        if (approvedCallers[account]) {
            approvedCallers[account] = false;
            emit ApprovedCallerRemoved(account);
        }
    }


    // **** Internal Logic ****

    function transferAllDistributionBalanceToTarget() internal returns (uint){
        // TODO : Use safe transfer
        uint distributionSelfBalance = ERC20(distributionToken).balanceOf(address(this));
        ERC20(distributionToken).transfer(targetRainMaker, distributionSelfBalance);
        uint distributionSelfBalanceAfter = ERC20(distributionToken).balanceOf(address(this));

        // TODO : Safe Math
        return distributionSelfBalanceAfter - distributionSelfBalance;
    }

    function reSyncTargetRainMakerInternal() internal {
        address activeRainMaker = IUnitrollerForCloudMaker(unitroller).rainMaker();

        targetRainMaker = activeRainMaker;
    }
}

pragma solidity ^0.7.6;

abstract contract CloudsMakerInterface {
    bool public isCloudsMaker = true;

    /*** Cloud Making ***/
    /**
     * Generates clouds and transfer them to the RainMaker
     */
    function condenseAndDispense() virtual external returns (uint dispensedTokens);
}



interface IUnitrollerForCloudMaker {
    function rainMaker() external returns (address);
}

pragma solidity ^0.7.6;

import "../../../Ola/Peripheral/CloudsMakers/CloudsMakerInterface.sol";
import "../TestErc20.sol";
import "hardhat/console.sol";

contract TestCloudsMaker is CloudsMakerInterface {

    address public rainMaker;
    // NOTE : Assumes the 'rainToken' is a 'TestErc20'
    TestErc20 public rainToken;


    // The amount of rain that will be minted upon each request
    uint public rainToMint;

    constructor(address _rainMaker, address _rainToken) {
        rainMaker = _rainMaker;
        rainToken = TestErc20(_rainToken);
    }

    function setRainToMint(uint _rainToMint) external {
        rainToMint = _rainToMint;
    }

    function condenseAndDispense() override external returns (uint dispensedTokens) {
        console.log("TestCloudsMaker::condenseAndDispense:: Called by %s | rain maker is %s", msg.sender, rainMaker);
        console.log("TestCloudsMaker::condenseAndDispense:: Will dispense %d of %s", rainToMint,  address(rainToken));

        rainToken.mint(rainMaker, rainToMint);

        dispensedTokens = rainToMint;
    }
}

pragma solidity ^0.7.6;

import "../../../Tools/Ownership/PendableAdminContractOwner.sol";
import "../../CloudsMakers/CloudsMakerInterface.sol";
import "hardhat/console.sol";

interface ISADRMForBudgeter {
    function comptroller() external view returns (IComptrollerForBudgeter);
    function _setDynamicCompSpeeds(address[] calldata _cTokens, uint[] calldata _compSupplySpeeds, uint[] calldata _compBorrowSpeeds) external;
}

interface IComptrollerForBudgeter {
    function getAllMarkets() external view returns (address[] memory);
}

interface IERC20ForBudgeter {
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint);
}

contract SingleAssetDynamicRainMakerBudgeter is PendableAdminContractOwner {

    event DistributionPeriodStarted(uint startsAt, uint period, uint budget);
    event NewBudget(uint oldBudget, uint newBudget);
    event StartsAtSet(uint oldStartsAt, uint newStartsAt);
    event DistributionPeriodSet(uint oldDistributionPeriod, uint newDistributionPeriod);
    event RatiosSet(uint supplyPart, uint borrowPart);
    event CloudMakerSet(address indexed oldCloudMaker, address indexed newCloudMaker);

    // *** Core budgeted-distribution values

    // Scaled as the rainToken
    uint public budget;

    // Could be represented by either seconds or blocks
    uint public startsAt;
    uint public distributionPeriod;

    // Each value represents a fraction (scaled by 10**18) and the whole array should sum up to 1.
    uint[] public supplySideDistributionRatios;
    uint[] public borrowSideDistributionRatios;

    // The cloud maker should transfer 'rainTokens' to the RainMaker Address
    address public rainToken;
    uint8 public rainTokenDecimals;
    CloudsMakerInterface public cloudsMaker;

    constructor(address _rainToken) {
        rainToken = _rainToken;
        rainTokenDecimals = IERC20ForBudgeter(rainToken).decimals();
    }

    // *** Derived budgeted-distribution computed values ***

    /**
     * Returns the (derived) block/timestamp in which the distribution ends.
     */
    function endsAt() public view returns (uint) {
        // TODO : SafeMath
        return startsAt + distributionPeriod;
    }

    /**
     * Returns the sum of all rain per distribution unit (block or second)
     */
    function totalRainPerBlockOrSecond() public view returns (uint) {
        if (distributionPeriod == 0 || budget == 0) {
            return 0;
        }

        // TODO : SafeMath
        return budget / distributionPeriod;
    }

    /**
     * Returns the amount of rainToken committed since the 'startTimeStamp'.
     * DEV_NOTE : If state is 'fresh' this should return 0
     */
    function budgetCommitmentUntilNow() public view returns (uint) {
        uint currentlyAt = getNow();

        if (currentlyAt >= endsAt()) {
            return budget;
        }

        // TODO : Safe Math for all
        uint completeUnit = 10**rainTokenDecimals;

        if (budget == 0 || distributionPeriod == 0) {
            return 0;
        }

        uint diff = currentlyAt - startsAt;
        uint scaledRatio = (diff * completeUnit) / distributionPeriod;

        uint rainCommitted = scaledRatio * budget / completeUnit ;

        return rainCommitted;
    }

    /**
     * Returns the amount of rain tokens that are not yet committed to distribution in the current distribution period.
     * DEV_NOTE : If state is 'fresh' this should return the value of 'budget'
     */
    function budgetRemaining() public view returns (uint) {
        uint rainCommitment = budgetCommitmentUntilNow();

        if (budget <= rainCommitment) {
            return 0;
        } else {
            // TODO : Check for edge cases (distribution ended etc) + safe
            return budget - rainCommitment;
        }
    }

    // *** Utility views ***

    function getSupplyRatios() external view returns (uint[] memory) {
        return supplySideDistributionRatios;
    }

    function getBorrowRatios() external view returns (uint[] memory) {
        return borrowSideDistributionRatios;
    }

    function getRainMaker() public view returns (ISADRMForBudgeter) {
        return ISADRMForBudgeter(address(ownedContract));
    }

    function hasCloudsMaker() public view returns (bool) {
        return address(cloudsMaker) != address(0);
    }

    /**
     * Returns the 'now' value of the current block, wither block number or timestamp.
     */
    function getNow() public view returns (uint) {
        // TODO : IMPORTANT : Support also timestamp
        return block.number;
    }

    /**
     * Calculates the fraction from the given amount.
     */
    function amountFromRatioAndTotal(uint ratio, uint total) public view returns (uint) {
        // TODO : Safe math
        uint completeUnit = 10**18;
        return ratio * total / completeUnit;
    }

    function balanceInRainTokens(address account) public view returns (uint) {
        return IERC20ForBudgeter(rainToken).balanceOf(account);
    }

    // **** Admin Setters ****

    /**
     * @notice : Setter for 'cloudsMaker'
     */
    function setCloudsMaker(address _cloudsMaker) external onlyOwner {
        setCloudMakerInternal(_cloudsMaker);
    }

    // *** Open (?) RM Budgeting ****

    /**
     * @notice re-calculates the rain speeds by the current (remaining) budget.
     *         IMPORTANT: Does not interact with the cloud maker
     * NOTE : When opening up to public interaction - add manual take
     *        add params of 'amount' and 'from' to enable manual rain increase (transfer from) (using safe transfer)
     */
    function reBudget() onlyOwner external {
        setStartsAtAndRemainingBudget();

        // Get some clouds while we are at it
        increaseBudgetFromCloudsMaker();

        reBudgetFreshInternal();
    }

    // *** Admin RM Budgeting ****

    // TODO : CRITICAL : Change function to 'emergency zero budget and speeds' that will be used in an emergency to stop all distribution.
    /**
     * Should not be used as part of the normal flow.
     * To be used for administrative needs.
     */
    function setBudgetAdministratively(uint newBudget) external onlyOwner  {
        setBudgetInternal(newBudget);
    }

    /**
     * DEV_NOTE : This function is intended to be removed once we have a better version of a budgeter.
     */
    function configureCoreParametersWithoutRebudgeting(uint distributionPeriod, uint[] calldata _supplySideDistributionRatios, uint[] calldata _borrowSideDistributionRatios) onlyOwner external {
        // DEV_NOTE : We assume that a budget=0 implies either an initial configuration or one that is already not active
        //            i.e the speeds are all zero.
        require(budget == 0, "Only when speeds are zero");

        setCoreParametersInternal(distributionPeriod, _supplySideDistributionRatios, _borrowSideDistributionRatios);
    }

    /**
     * @notice Allows the setting of all budget parameters .
     * After setting the parameters, the cloud maker will be asked to make some clouds and a re-budget will occur
     * (taking into account the newly made clouds), i.e. the rain (maker's) speeds will be set accordingly.
     * The setting is intentionally atomic.
     *
     * @param distributionPeriod The length of the distribution that will be set by each re-budgeting. A 0 value will mean the immediate halt of further distribution (can be resumed later).
     * @param _supplySideDistributionRatios The wanted supply ratios. Both arrays together should sum up to 10**18. Both arrays must have same length (equal to the supported markets of the rain maker) or 0 (empty array).
     * @param _borrowSideDistributionRatios The wanted borrow ratios. Both arrays together should sum up to 10**18. Both arrays must have same length (equal to the supported markets of the rain maker) or 0 (empty array)
     * @param manualBudgetIncrease Utility param to allow pre-funding the RM before the re-budget.
     */
    function configureCoreParametersWithReBudget(uint distributionPeriod, uint[] calldata _supplySideDistributionRatios, uint[] calldata _borrowSideDistributionRatios, uint manualBudgetIncrease) onlyOwner external {
        // Freshen the state
        setStartsAtAndRemainingBudget();

        // Get some clouds while we are at it
        increaseBudgetFromCloudsMaker();

        // Manual increase ?
        if (manualBudgetIncrease > 0) {
            increaseBudget(manualBudgetIncrease);
        }

        // Set the budget params before calculating new budget and speeds
        setCoreParametersInternal(distributionPeriod, _supplySideDistributionRatios, _borrowSideDistributionRatios);

        // 'No budget' should only occur at the very initial steps of the budgeter
//        if (budget > 0) {
        reBudgetFreshInternal();
//        }
    }

    // **** Internal Logic ****

    /**
     * If there is a connected cloud maker, ask for some cloud and increase the remaining budget.
     * Important : This function only affects the 'budget' state param and will not change the rain speeds.
     */
    function increaseBudgetFromCloudsMaker() internal {
        uint budgetIncrease;
        uint rainGain;

        if (hasCloudsMaker()) {
            rainGain = callCloudMakerInternal();
        }

        increaseBudget(rainGain);
    }

    function callCloudMakerInternal() internal returns (uint rainTokensGain) {
        address rainMakerAddress = address(getRainMaker());
        uint rainMakerBalanceBefore = balanceInRainTokens(rainMakerAddress);
        uint rainTokensSent = cloudsMaker.condenseAndDispense();

        uint rainMakerBalanceAfter = balanceInRainTokens(rainMakerAddress);

        rainTokensGain = rainMakerBalanceAfter - rainMakerBalanceBefore;
    }

    function setCoreParametersInternal(uint distributionPeriod, uint[] calldata _supplySideDistributionRatios, uint[] calldata _borrowSideDistributionRatios) internal {
        // Distribution period is set directly
        setDistributionPeriodInternal(distributionPeriod);

        setDistributionRatiosOrKeepExistingInternal(_supplySideDistributionRatios, _borrowSideDistributionRatios);
    }

    /**
     * Sets the rain speeds using the current budget.
     * Any change to the budget should occur before calling this function
     */
    function reBudgetFreshInternal() internal  {
        // Sanity
        require(startsAt == getNow(), "Not fresh!");

        address[] memory allMarkets = getRainMaker().comptroller().getAllMarkets();

        // Map ratios to actual speeds
        uint[] memory supplySpeeds = new uint[](supplySideDistributionRatios.length);
        uint[] memory borrowSpeeds = new uint[](borrowSideDistributionRatios.length);

        uint rainPerUnit = totalRainPerBlockOrSecond();

        for (uint i = 0; i < supplySpeeds.length; i++) {
            supplySpeeds[i] = amountFromRatioAndTotal(supplySideDistributionRatios[i], rainPerUnit);
            borrowSpeeds[i] = amountFromRatioAndTotal(borrowSideDistributionRatios[i], rainPerUnit);
        }

        // External call !
        getRainMaker()._setDynamicCompSpeeds(allMarkets, supplySpeeds, borrowSpeeds);

        // TODO : Events ?
        emit DistributionPeriodStarted(startsAt, distributionPeriod, budget);
    }

    // **** Internal Setters ****

    /**
     * Safe set allows a 'keep existing' option
     */
    function setDistributionRatiosOrKeepExistingInternal(uint[] calldata _supplySideDistributionRatios, uint[] calldata _borrowSideDistributionRatios) internal {
        if (_supplySideDistributionRatios.length == 0 ) {
            require(_borrowSideDistributionRatios.length == 0, "Arrays must be both empty or both of the same length.");
            return;
        }

        setDistributionRatiosInternal(_supplySideDistributionRatios, _borrowSideDistributionRatios);
    }

    function setDistributionRatiosInternal(uint[] calldata _supplySideDistributionRatios, uint[] calldata _borrowSideDistributionRatios) internal {
        // Sanity -- Lengths should match
        require(_supplySideDistributionRatios.length == _borrowSideDistributionRatios.length, "Distribution ratios must have equal length");
        require(getRainMaker().comptroller().getAllMarkets().length == _borrowSideDistributionRatios.length, "Distribution ratios must equal supported markets length");

        // Sanity -- both arrays should sum up to 1 (10**18)
        uint completeUnit = 10**18;
        uint supplyRatiosSum;
        uint borrowRatiosSum;

        for (uint i; i < _supplySideDistributionRatios.length; i++) {
            supplyRatiosSum += _supplySideDistributionRatios[i];
            borrowRatiosSum += _borrowSideDistributionRatios[i];
        }

        require(supplyRatiosSum + borrowRatiosSum == completeUnit, "Supply and Borrow ratios do not sum up to 1");

        supplySideDistributionRatios = _supplySideDistributionRatios;
        borrowSideDistributionRatios = _borrowSideDistributionRatios;

        // TODO : Events ?
        emit RatiosSet(supplyRatiosSum, borrowRatiosSum);
    }

    function setCloudMakerInternal(address newCloudsMaker) internal {
        // Sanity
        require(CloudsMakerInterface(newCloudsMaker).isCloudsMaker(), "Not a cloud maker");

        address oldCloudMaker = address(cloudsMaker);
        cloudsMaker = CloudsMakerInterface(newCloudsMaker);

        emit CloudMakerSet(oldCloudMaker, address(cloudsMaker));
    }

    function increaseBudget(uint budgetToAdd) internal {
        // DEV_NOTE : When moving this logic into the RM, we should reduce the budget first thing
        //            (as part of the 'ensure state is fresh up to this point')
        uint currentBudget = budget;

        // TODO : Safe math
        setBudgetInternal(currentBudget + budgetToAdd);
    }

    function setStartsAtAndRemainingBudget() internal {
        setBudgetToRemaining();

        setStartsAt(getNow());
    }

    function setStartsAt(uint newStartsAt) internal {
        uint oldStartsAt = startsAt;
        startsAt = newStartsAt;

        emit StartsAtSet(oldStartsAt, startsAt);
    }

    function setBudgetToRemaining() internal {
        uint remainingBudget = budgetRemaining();

        setBudgetInternal(remainingBudget);
    }

    function setBudgetInternal(uint newBudget) internal {
        uint oldBudget = budget;
        budget = newBudget;

        emit NewBudget(oldBudget, newBudget);
    }

    function setDistributionPeriodInternal(uint newDistributionPeriod) internal {
        uint oldDistributionPeriod = distributionPeriod;
        distributionPeriod = newDistributionPeriod;

        emit DistributionPeriodSet(oldDistributionPeriod, newDistributionPeriod);
    }
}

pragma solidity ^0.7.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IPendableAdminContractOwner.sol";

contract PendableAdminContractOwner is Ownable, IPendableAdminContractOwner {
    IPendableAdminContractForOwner ownedContract;

    function getOwnedContract() external view override returns (address) {
        return address(this);
    }

    function acceptContractOwnership(address contractToOwn) onlyOwner override  external {
        // Sanity
        require(IPendableAdminContractForOwner(contractToOwn).pendingAdmin() == address(this), "Not pendable admin");

        // Keep for event
        address oldAdmin =  IPendableAdminContractForOwner(contractToOwn).admin();

        // Keep for callbacks
        address oldOwnedContract =  address(ownedContract);

        // Accept admin
        IPendableAdminContractForOwner(contractToOwn)._acceptAdmin();

        // This will make sure all admins were properly replaced
        safeSetOwnedContract(contractToOwn);

        // Potential callback
        _afterAcceptingOwnership(oldOwnedContract, address(ownedContract));

        // Events
        emit OwnershipTaken(contractToOwn, oldAdmin);
    }

    function offerOwnedContractOwnershipTo(address newOwner) onlyOwner override external {
        // Sanity
        require(address(ownedContract) != address(0), "No Owned contract");
        require(ownedContract.admin() == address(this), "not admin of owned contract!");

        ownedContract._setPendingAdmin(newOwner);

        emit OwnershipProposed(address(ownedContract), newOwner);
    }

    // **** Internal Setters ****

    function safeSetOwnedContract(address newContractToOwn) internal {
        if (address(ownedContract) == newContractToOwn) {
            return;
        }

        address oldOwnedContract = address(ownedContract);
        IPendableAdminContractForOwner newPendableAdminContractToOwn = IPendableAdminContractForOwner(newContractToOwn);

        address newContractToOwnAdmin = newPendableAdminContractToOwn.admin();

        // Sanity -- Ensure this contract is indeed the owner
        require(newContractToOwnAdmin == address(this), "Not admin of new contract");

        // This check is crucial to avoid leaving a contract in an admin limbo, if we currently (think that we) own a contract, make sure
        // this is no longer the case
        if (oldOwnedContract != address(0)) {
            address oldOwnedContractAdmin = IPendableAdminContractForOwner(oldOwnedContract).admin();
            require(oldOwnedContractAdmin != address(this), "Must wait to previous owned contract ownership transferring");
        }

        // If we got here, it means all sanity and safety tests have passed
        ownedContract = newPendableAdminContractToOwn;

        emit NewOwnedContract(oldOwnedContract, newContractToOwn);
    }

    // **** Empty Virtual Callbacks ****

    function _afterAcceptingOwnership(
        address oldOwnedContract,
        address newOwnedContract
    ) internal virtual {}
}

pragma solidity ^0.7.6;

/**
 * This contract is used as a stand-in interface.
 * Other contract do not currently inherit from this contract but should inherit a similar one soon.
 */
interface IPendableAdminContractForOwner {
    event NewAdmin(address oldAdmin, address newAdmin);
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    function admin() view external returns (address);
    function pendingAdmin() view external returns (address);

    function _setPendingAdmin(address newAdmin) external;
    function _acceptAdmin() external;
}

interface IPendableAdminContractOwner {
    event NewOwnedContract(address indexed oldOwnedContract, address indexed newOwnedContract);
    event OwnershipProposed(address indexed owendContract, address indexed propusedOwner);
    event OwnershipTaken(address indexed owendContract, address indexed previousOwner);

    function acceptContractOwnership(address contractToOwen) external virtual;
    function offerOwnedContractOwnershipTo(address newOwner) external virtual;

    function getOwnedContract() external view virtual returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokensLens {

    struct ERC20Metadata {
        address token;
        uint8 decimals;
        string symbol;
    }

    function erc20TokenMeta(ERC20 erc20Token) public view returns (ERC20Metadata memory) {
        return ERC20Metadata({
        token: address(erc20Token),
        decimals: erc20Token.decimals(),
        symbol: erc20Token.symbol()
        });
    }

    function erc20TokenBalance(ERC20 erc20Token, address owner) public view returns (uint) {
        return erc20Token.balanceOf(owner);
    }

    function erc20TokenAllowance(ERC20 erc20Token, address owner, address spender) public view returns (uint) {
        return erc20Token.allowance(owner, spender);
    }

    function erc20TokenAllowanceWithDecimals(ERC20 erc20Token, address owner, address spender) public view returns (uint allowances, uint decimals) {
        return (erc20Token.allowance(owner, spender), erc20Token.decimals());
    }


    function erc20MetadataAll(ERC20[] calldata erc20Tokens) public view returns (ERC20Metadata[] memory) {
        uint tokensCount = erc20Tokens.length;
        ERC20Metadata[] memory res = new ERC20Metadata[](tokensCount);
        for (uint i = 0; i < tokensCount; i++) {
            res[i] = erc20TokenMeta(erc20Tokens[i]);
        }
        return res;
    }

    function erc20BalancesAll(ERC20[] calldata erc20Tokens, address owner) public view returns (uint[] memory) {
        uint tokensCount = erc20Tokens.length;
        uint[] memory res = new uint[](tokensCount);
        for (uint i = 0; i < tokensCount; i++) {
            res[i] = erc20TokenBalance(erc20Tokens[i], owner);
        }
        return res;
    }

    function erc20AllowancesAll(ERC20[] calldata erc20Tokens, address owner, address spender) public view returns (uint[] memory) {
        uint tokensCount = erc20Tokens.length;
        uint[] memory res = new uint[](tokensCount);
        for (uint i = 0; i < tokensCount; i++) {
            res[i] = erc20TokenAllowance(erc20Tokens[i], owner, spender);
        }
        return res;
    }

    function erc20AllowancesMultiple(ERC20[] calldata erc20Tokens, address owner, address[] calldata spenders) public view returns (uint[] memory) {
        require(erc20Tokens.length == spenders.length, "Tokens and spenders must have same length");
        uint tokensCount = erc20Tokens.length;
        uint[] memory res = new uint[](tokensCount);
        for (uint i = 0; i < tokensCount; i++) {
            res[i] = erc20TokenAllowance(erc20Tokens[i], owner, spenders[i]);
        }
        return res;
    }

    function erc20MetadataAndBalanceAll(ERC20[] calldata tokens, address owner) public view  returns (ERC20Metadata[] memory, uint[] memory) {
        ERC20Metadata[] memory metas = erc20MetadataAll(tokens);
        uint[] memory balances = erc20BalancesAll(tokens, owner);
        return (metas, balances);
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../../../OlaPlatform/Factories/BaseMinistryFactory.sol";
import "../../../OlaPlatform/Factories/IODelegatorMInistryFactory.sol";

interface IODelegatorDeployerForFactory {
    function deployODelegator(
        address underlying_,
        address comptroller_,
        address interestRateModel_,
        uint initialExchangeRateMantissa_,
        string calldata name_,
        string calldata symbol_,
        uint8 decimals_,
        address payable admin_,
        bytes calldata becomeImplementationData
    ) external returns (address);
}

/// @title Ola ODelegator Ministry Factory
/// @notice Manages deployment of ODelegators for the ministry.
contract ODelegatorFactoryV0_01 is BaseMinistryFactory, IODelegatorMinistryFactory {
    using SafeMath for uint;

    // address constant public nativeCoinUnderlying = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    bytes32 constant public ONativeDelegatorContractHash = keccak256("ONativeDelegator");
    bytes32 constant public CErc20DelegatorContractHash = keccak256("CErc20Delegator");

    string public nativeCoinName;
    string public oNativeName;
    string public oNativeSymbol;
    IODelegatorDeployerForFactory public oNativeDelegatorDeployer;
    IODelegatorDeployerForFactory public cErc20DelegatorDeployer;

    // All OTokens will have 8 decimals
    uint8 public oDelegatorDecimals = 8;

    // All ONativeDelegators will start with the exact same exchange rate mantissa (0.02 scaled by native decimals + 10, so 28)
    uint public initialExchangeRateMantissaForNative = 200000000000000000000000000;

    constructor(address _ministry, string memory _nativeCoinName, string memory _nativeCoinSymbol, address oNativeDelegatorDeployerAddress, address cErc20DelegatorDeployerAddress) BaseMinistryFactory(_ministry){
        oNativeDelegatorDeployer = IODelegatorDeployerForFactory(oNativeDelegatorDeployerAddress);
        cErc20DelegatorDeployer = IODelegatorDeployerForFactory(cErc20DelegatorDeployerAddress);
        nativeCoinName = _nativeCoinName;

        // Deriving oNative params
        oNativeName = concat("Ola ", _nativeCoinName);
        oNativeSymbol = concat("o", _nativeCoinSymbol);
    }

    struct ODelegatorDeploymentParameters {
        uint initialExchangeRateMantissa;
        string name;
        string symbol;
        uint8 decimals;
    }

    function deployODelegator(
        address underlying,
        bytes32 contractNameHash,
        bytes calldata params,
        address comptroller,
        address interestRateModel,
        address payable admin,
        bytes calldata becomeImplementationData
    ) external override returns (address) {
        // Ensure ministry is the caller
        require(isFromMinistry(), "Only the Ministry can call the factory");

        IODelegatorDeployerForFactory deployer;
        address deployedContract;

        ODelegatorDeploymentParameters memory oDelegatorDeploymentParameters;
        oDelegatorDeploymentParameters.decimals = oDelegatorDecimals;

        if (underlying == nativeCoinUnderlying) {
            if (contractNameHash == ONativeDelegatorContractHash) {
                deployer = oNativeDelegatorDeployer;

                // Take constant parameters for Native
                oDelegatorDeploymentParameters.initialExchangeRateMantissa = initialExchangeRateMantissaForNative;
                oDelegatorDeploymentParameters.name = oNativeName;
                oDelegatorDeploymentParameters.symbol = oNativeSymbol;
            } else {
                revert("Unsupported contract name hash for Native coin");
            }
        } else {
            if (contractNameHash == CErc20DelegatorContractHash) {
                deployer = cErc20DelegatorDeployer;

                uint8 underlyingDecimals = ERC20(underlying).decimals();

                // Calculate parameters for ERC20
                oDelegatorDeploymentParameters.initialExchangeRateMantissa = calculateInitialExchangeRateMantissaForCERC20(underlyingDecimals);
                oDelegatorDeploymentParameters.name = concat("Ola ", ERC20(underlying).name());
                oDelegatorDeploymentParameters.symbol = concat("o", ERC20(underlying).symbol());

            } else {
                revert("Unsupported contract name hash for ERC20 token");
            }
        }

        deployedContract = deployer.deployODelegator(
            underlying,
            comptroller,
            interestRateModel,
            oDelegatorDeploymentParameters.initialExchangeRateMantissa,
            oDelegatorDeploymentParameters.name,
            oDelegatorDeploymentParameters.symbol,
            oDelegatorDeploymentParameters.decimals,
            admin,
            becomeImplementationData);

        return deployedContract;
    }

    /// @notice Util for concating strings
    function concat(string memory a, string memory b) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }

    /// @notice Calculate the initial exchange rate mantissa (0.02 scaled by underlyingDecimals + 10)
    function calculateInitialExchangeRateMantissaForCERC20(uint8 underlyingDecimals) internal pure returns (uint) {
        // Sanity
        require(underlyingDecimals <= 30, "Too big decimals");

        // 0.02 * (e10)
        uint baseInitialExchangeRateScaledBy10 = 200000000;
        uint initialExchangeRateMantissa = baseInitialExchangeRateScaledBy10 * (10 ** underlyingDecimals);

        return initialExchangeRateMantissa;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

/// @title Ola Base Ministry Factory
/// @notice Manages access to factory to only allow calls from the Ministry.
contract BaseMinistryFactory {
    address public ministry;

    constructor(address _ministry) {
        ministry = _ministry;
    }

    function isFromMinistry() internal view returns (bool) {
        return msg.sender == ministry;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "./BaseMinistryFactory.sol";

/// @title Ola ODelegator Ministry Factory
/// @notice Manages deployment of ODelegators for the ministry.
abstract contract  IODelegatorMinistryFactory {
    address constant public nativeCoinUnderlying = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function deployODelegator(address underlying, bytes32 contractNameHash, bytes calldata params, address comptroller, address interestRateModel_, address payable admin, bytes calldata becomeImplementationData) external virtual returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "../0.01/ODelegatorFactoryV0_01.sol";

/**
 * @title Ola ODelegator Factory V0.02
 * @notice Manages deployment of ODelegators for the ministry.
 * -- Changes form V0.01 : NONE
 */
contract ODelegatorFactoryV0_02 is ODelegatorFactoryV0_01 {
    constructor(address _ministry, string memory _nativeCoinName, string memory _nativeCoinSymbol, address oNativeDelegatorDeployerAddress, address cErc20DelegatorDeployerAddress)
        ODelegatorFactoryV0_01(_ministry,  _nativeCoinName, _nativeCoinSymbol, oNativeDelegatorDeployerAddress, cErc20DelegatorDeployerAddress){
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "./BaseMinistryFactory.sol";

abstract contract IPeripheryMinistryFactory is BaseMinistryFactory {
    function deployPeripheryContract(bytes32 contractNameHash, address _comptroller, address _admin, bytes calldata params) external virtual returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "../../../Core/OlaPlatform/Factories/PeripheryMinistryFactory.sol";

interface ISingleAssetDynamicRainMakeDeployer {
    function deploy(address comptroller, address admin) external returns (address);
}

interface IWhitelistBouncerDeployer {
    function deploy(address comptroller, address admin) external returns (address);
}

contract PeripheralFactory is IPeripheryMinistryFactory {

//    bytes32 constant public SingleAssetRainMakerContractHash = keccak256("SingleAssetRainMaker");
    bytes32 constant public SingleAssetDynamicRainMakerContractHash = keccak256("SingleAssetDynamicRainMaker");
    bytes32 constant public WhiteListBouncerContractHash = keccak256("WhiteListBouncer");


    ISingleAssetDynamicRainMakeDeployer singleAssetDynamicRainMakerDeployer;
    IWhitelistBouncerDeployer whitelistBouncerDeployer;

    constructor(address _ministry, address _singleAssetDynamicRainMakerDeployer, address _whitelistBouncerDeployer) BaseMinistryFactory(_ministry) {
        singleAssetDynamicRainMakerDeployer = ISingleAssetDynamicRainMakeDeployer(_singleAssetDynamicRainMakerDeployer);
        whitelistBouncerDeployer = IWhitelistBouncerDeployer(_whitelistBouncerDeployer);
    }

    function deployPeripheryContract(bytes32 contractNameHash, address _comptroller, address _admin, bytes calldata params) external override returns (address) {
        require(isSupportedContract(contractNameHash), "Unsupported contract name hash");

        if (contractNameHash == SingleAssetDynamicRainMakerContractHash) {
            return singleAssetDynamicRainMakerDeployer.deploy(_comptroller, _admin);
        } else if (contractNameHash == WhiteListBouncerContractHash) {
            return whitelistBouncerDeployer.deploy(_comptroller, _admin);
        }

        // This is here as a safety mechanism that will fail when given a bad address
        require(1==2, "Emergency safety");
        return address(0);
    }

    function isSupportedContract(bytes32 contractNameHash) public pure returns (bool) {
        return (contractNameHash == SingleAssetDynamicRainMakerContractHash || contractNameHash == WhiteListBouncerContractHash);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.6;

import "./OpenOracleData.sol";

/**
 * @title The Open Oracle View Base Contract
 * @author Compound Labs, Inc.
 */
contract OpenOracleView {
    /**
     * @notice The Oracle Data Contract backing this View
     */
    OpenOracleData public priceData;

    /**
     * @notice The static list of sources used by this View
     * @dev Note that while it is possible to create a view with dynamic sources,
     *  that would not conform to the Open Oracle Standard specification.
     */
    address[] public sources;

    /**
     * @notice Construct a view given the oracle backing address and the list of sources
     * @dev According to the protocol, Views must be immutable to be considered conforming.
     * @param data_ The address of the oracle data contract which is backing the view
     * @param sources_ The list of source addresses to include in the aggregate value
     */
    constructor(OpenOracleData data_, address[] memory sources_) public {
        require(sources_.length > 0, "Must initialize with sources");
        priceData = data_;
        sources = sources_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "hardhat/console.sol";

contract FailureMaker {
    constructor () {
    }

    function pleaseRevert() external {
        require(false, "Reverting this tx");
    }

    function pleaseReturnFalse() public returns (bool) {
        return false;
    }
}