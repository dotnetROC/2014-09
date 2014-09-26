function Invoke-DemoMagic {
    param($step)

    switch($step) {
        "about.html" {
            $AboutUs = @'
<div class="row">
    <h2>VDUNY</h2>
    <p>
        Welcome to the Visual Developers of Upstate NY website. We are a group of
        several hundred developers, programmers, designers, and system architects in
        upstate New York, mostly in and around the Rochester area. If you are interested
        in learning and sharing information about Visual Software Development, you
        should check out this group!</p>
    <h3>Mission:</h3>
    <p>
        The VDUNY computer club's main mission is to provide a forum and an opportunity
        to exchange ideas, knowledge and experience about developing applications with a
        visual interface. This includes our old favorite like the Microsoft visual
        development tools (such as VB.NET, C#, SQL Server, Windows Phone, etc.), as
        well as other languages and formats like HTML, ASP, JAVA, XML, and many
        others. If it has a visual interface and it needs to be programmed, we will
        probably discuss it!</p>
    <h3>Meetings:</h3>
    <p>
        Generally the 4th Thursday of each month 6:00pm - 8:30pm (food will arrive at
        6:00pm and the meeting will start about 6:30) at New Horizons Computer Learning
        Center, 50 Methodist Hill Drive, Henrietta, NY 14623. <i>Unless the meeting
        is sponsored, please bring $4 to help cover cost of the food and pop.  Make sure
        that you have joined the VDUNY email List Server so you receive all
        of the meeting announcements and that you RSVP so that we have an accurate count of the attendees.</i></p>
    <p>
        Feel free to invite other interested colleagues, friends and coworkers. There is no membership fee.</p>
</div>
'@
            $About = Import-Html about.html

            $About | Update-Xml -Remove "//div[@class='jumbotron']"
            $About | Update-Xml -Replace "//div[@class='row']" $AboutUs
            # fix the css style
            $about.html.head.style.innertext = $about.html.head.style."#cdata-section"
            $text = "<!DOCTYPE html>" + $about.OuterXml
            $text = $text -replace ([char]169),"&copy;"

            Set-Content about.html $text -Encoding UTF8
        }
    }
}
