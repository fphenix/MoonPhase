// Fred Limouzin 02/03/2017
// Updated : 12/03/2017
//
// This is coded based on "Lunar Phase Computation" by Stephen R. Schmitt
// reference: "Sky & Telescope, Astronomical Computing", April 1994
//
// Only Northern hemisphere supported right now!!

// Lunar Phase Computation
class LPC {
  String dateYYYYMMDD;
  int dayOffset;
  float pc;       // age of moon in percent
  float distance; // in Earth radii (1 Er ~= 6371 km)
  String distName;
  float distKm;
  float earthRadii = 6371; // km (about)
  float eclipticLatitude, eclipticLongitude;
  float moonAge;  // age of moon in days
  String zodiac;
  String phase;
  float illum;    // % of illumination
  //
  float[] rx;
  float ry;
  float radius;
  float offsety;
  float stepy;
  PVector moonC;

  LPC () {
    this.rx = new float[2];
    this.radius = 100.0;
    this.offsety = 20.0;
    this.moonC = new PVector(width/2, this.radius + this.offsety);
    this.ry = this.radius;
    this.stepy = 1.0;
  }

  void moonIt (PImage img) {
    imageMode(CENTER);
    image(img, this.moonC.x, this.moonC.y);
  }

  void shadeIt () {
    this.ComputeLunarPhase();
    this.zodiac = this.getZodiac();
    this.distName = this.lunarDistance();
    this.EllipsePhase();
    this.EllipseMask();
  }

  //build the mask shape that will hide the moon where needs be
  void EllipseMask () {
    float temp;
    float x;
    float yy;
    stroke(24);
    strokeWeight(1);
    fill(24, 240); // with a bit of alpha
    // 2 half arcs depending on the rx[] values
    beginShape(); 
    for (int i = 0; i < 2; i++) {
      for (float y = -this.ry; y <= this.ry; y = y + this.stepy) {
        yy = (1 - (2*i)) * y; // yy=y for i=0 and yy=-y for i=1
        temp = sqrt(1 - ((yy*yy) / (this.ry*this.ry)));
        x = this.rx[i] * temp;
        vertex(this.moonC.x+x, this.moonC.y+yy);
      }
    }
    endShape();
  }

  //---------------------------------------------------
  // p in percent of a full cycle within [0;100]
  // 0% and 100% : new moon; 50% full moon; etc.
  // This gives an approximation for a flat Moon rather than a spherical Moon. 
  // But after all it is well known that the Earth is flat, so the Moon must be too...
  //---------------------------------------------------
  void EllipsePhase () {
    //if      moonAge <  1.84566 then Phase = "NEW"
    //else if moonAge <  5.53699 then Phase = "Waxing crescent"
    //else if moonAge <  9.22831 then Phase = "First quarter"
    //else if moonAge < 12.91963 then Phase = "Waxing gibbous"
    //else if moonAge < 16.61096 then Phase = "FULL"
    //else if moonAge < 20.30228 then Phase = "Waning gibbous"
    //else if moonAge < 23.99361 then Phase = "Last quarter"
    //else if moonAge < 27.68493 then Phase = "Waning crescent"
    //else                            Phase = "NEW"
    String[] phasesLst = {"New Moon", "Waxing Crescent", "First Quarter", "Waxing Gibbous", "Full Moon", "Waning Gibbous", "Last Quarter", "Waning Crescent"};
    float temp = 8.0 * ((this.pc/100.0) + (1.0/16.0)); // warning!! "float t = 49/100;" gives 0.0 whereas "float t = 49.0/100;" gives 0.49...
    int idx = floor(temp) % 8;
    phase = phasesLst[idx];
    float[] normRx = new float[2];

    //Prepare for the 2 half-circles that will be used to compute the mask
    if (this.pc < 50.0) {
      // during the first half of the cycle,
      // one border of the shape stays on the left side (-1)
      // (when the other one moves from right (+1) to left (-1))
      normRx[0] = -1.0;
    } else {
      // during the 2nd half of the cycle,
      // one border of the shape stays on the right side (+1)
      // (when the other one moves again from right (+1) to left (-1))
      normRx[0] = 1.0;
    }
    // In the meantime, the second border goes from right (+1) to left ( -1) 
    // side during the first and the second halves of the cycle
    // Could do like this: 
    //   normRx[1] = 1.0 - ((this.pc % 50) / 25.0);
    // but let's try to include 3D with cos()
    float ztheta = 2.0 * PI * (this.pc % 50)/100;
    normRx[1] = cos(ztheta);

    this.rx[0] = normRx[0] * this.radius;
    this.rx[1] = normRx[1] * this.radius;
  }

  // -----------------------------------------------------------------------------------------
  // based on "Lunar Phase Computation" by Stephen R. Schmitt, 2005
  // Ref: "Sky & Telescope, Astronomical Computing", April 1994
  // Also a bit from the R4MFCL project developed by the Secretariat of the Pacific Community (SPC)
  // -----------------------------------------------------------------------------------------
  // note: I don't pretend to understand all the constants in there...
  // -----------------------------------------------------------------------------------------
  //normalize values within 0 to 1 range
  float normIt (float val) {
    float v = val - floor(val);
    if (v < 0) {
      v = v + 1;
    }
    return v;
  }

  float getJulianOrGregorianDay () {
    this.dayOffset = floor(map(mouseX, 0, width, -30, 30));
    Calendar calendar = Calendar.getInstance();
    Date currDate =  calendar.getTime();

    calendar.setTime(currDate);
    calendar.set(Calendar.MILLISECOND, 0);
    calendar.set(Calendar.SECOND, 0);
    calendar.set(Calendar.MINUTE, 0);
    calendar.set(Calendar.HOUR_OF_DAY, 12);
    calendar.add(Calendar.DAY_OF_YEAR, dayOffset);

    //dayOffset = 0;
    int d = calendar.get(Calendar.DAY_OF_MONTH); // day() + int(dayOffset);
    int m = calendar.get(Calendar.MONTH) + 1; // month();
    int y = calendar.get(Calendar.YEAR); // year();

    float shiftH = 0; // shift in hours from the 12h UT
    this.dateYYYYMMDD = y + "/" + m + "/" + d;
    //Julian date at 12h UT
    float julianYear = y - floor((12.0 - m) / 10.0);
    float julianMonth = (m + 9.0) % 12; // 0 to 11

    int k1 = floor(365.25 * (julianYear + 4712.0));
    int k2 = floor((30.6001 * julianMonth) + 0.5 + (shiftH*24));
    int k3 = floor(floor((julianYear / 100.0) + 49.0) * 0.75) - 38;

    float julianDay = k1 + k2 + d + 59; // day in Julian Calendar
    float gregorianDay = julianDay - k3;// day in Gregorian Calendar
    return (julianDay > 2299160) ? gregorianDay : julianDay;
  }

  void ComputeLunarPhase () {
    float jgDay = this.getJulianOrGregorianDay();

    // Moon's "age" in days
    float maxAge = 29.530588853;
    float ip = (jgDay - 2451550.1) / maxAge;
    float ipNormalized = this.normIt(ip);
    float ipRad = ipNormalized * PI; // convert to radian
    this.moonAge = ipNormalized * maxAge;

    this.pc = 100.0 * this.moonAge/maxAge;

    //Calculate illumination approximation
    this.illum = 100.0 * (1.0 - ((1.0 + cos(2 * PI * this.pc / 100.0)) /2.0));

    // calculate moon's distance
    float temp = (jgDay - 2451562.2 ) / 27.55454988;
    float dp = 2.0 * PI * this.normIt(temp);
    this.distance = 60.4 - 3.3*cos(dp) - 0.6*cos((2*ipRad) - dp) - (0.5*cos(2*ipRad));
    this.distKm = this.earthRadii * this.distance;

    // calculate moon's ecliptic latitude
    temp = (jgDay - 2451565.2) / 27.212220817;
    float np = 2.0 * PI * this.normIt(temp);
    this.eclipticLatitude = 5.1 * sin(np);

    // calculate moon's ecliptic longitude
    temp = (jgDay - 2451555.8) / 27.321582241;
    float rp = this.normIt(temp);
    temp  = (360.0 * rp) + (6.3*sin(dp));
    temp += 1.3*sin(2.0*ipRad - dp);
    temp += 0.7*sin(2.0*ipRad);
    this.eclipticLongitude = temp;
  }

  String lunarDistance () {
    String[] distNames = {"Apogee", "Far", "Average", "Near", "Perigee"};
    float refd;

    for (int i = 1; i <= distNames.length; i++) {
      refd = 56.0 + (i * ((63.8-56)/5) );
      if (this.distance < refd) {
        return distNames[(distNames.length-i)];
      }
    }
    return distNames[0];
  }

  String getZodiac () {
    float[] eLvals = {33.18, 51.16, 93.44, 119.48, 135.30, 173.34, 224.17, 242.57, 271.26, 302.49, 311.72, 348.58};
    String[] eLzod = {"Pisces", "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo", "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius"};
    String ret = eLzod[0];
    for (int i = 0; i < eLvals.length; i++) {
      if (this.eclipticLongitude < eLvals[i]) {
        ret = eLzod[i];
        break;
      }
    }
    return ret;
  }
  // End fo part "based on ...."
  // -----------------------------------------------------------------------------------------

  // completely useless but cool stars methods!!
  void starsInit () {
    for (int n = 0; n < 100; n++) {
      strokeWeight(random(3));
      stroke(random(64, 255));
      point(random(width), random(width)); // 2nd is also 'width' (not height) so no stars in text zone!
      loadPixels(); // store stars background
    }
  }

  void stars() {
    updatePixels(); // load stars background
  }

  // -----------------------------------------------------
  void display () {
    float tx, ty;
    float offsettxt = this.offsety;
    tx = 50;
    ty = height/2 + this.offsety*3;
    fill(255);
    text("Date (Y/m/d): " + this.dateYYYYMMDD + " @ 12h UT", tx, ty);
    ty += offsettxt;
    text("Offset in days from today: " + this.dayOffset, tx, ty);
    ty += offsettxt;
    text("Moon Age (days): " + this.moonAge + " (" + round(this.pc) + "%)", tx, ty);
    ty += offsettxt;
    text("Moon in constellation: " + this.zodiac, tx, ty);
    ty += offsettxt;
    text("Moon Phase: " + this.phase, tx, ty);
    ty += offsettxt;
    text("% Illumination: " + round(this.illum), tx, ty);
    ty += offsettxt;
    text("Distance from Earth: " + floor(this.distance) + " Er (" + floor(this.distKm) + " km)", tx, ty);
    ty += offsettxt;
    text("Distance from Earth: " + this.distName, tx, ty);
    ty += offsettxt;
    text("Ecliptic lat, Lon: " + this.eclipticLatitude + ", " + this.eclipticLongitude, tx, ty);
    ty += offsettxt;
  }
}
