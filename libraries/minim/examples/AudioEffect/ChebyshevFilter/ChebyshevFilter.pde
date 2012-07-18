/**
 * This sketch demonstrates how to use a Chebyshev Filter. A Chebyshev Filter is used to 
 * separate one band of frequencies from another. It can either be a Low Pass filter or 
 * a High Pass filter. This type, along with three other attributes are used to determine 
 * the coefficients used for processing a signal. The other three attributes are the cutoff frequency, 
 * the passband ripple percentage, and the number of poles.
 * <p>
 * The cutoff frequency is the frequency that defines the breakpoint between the filter's passband
 * and stopband. If the ChebFilter is set to be a low pass filter and the cutoff frequency is 500 Hz, 
 * Then all frequencies in a signal below 500 Hz will be allowed through the filter and the frequencies 
 * above 500 Hz will removed. So 0 to 500 Hz is the passband and 500 Hz to one-half of the sampling rate 
 * (22050 Hz if you are sampling at 44100 Hz, which is typical) is the stopband.
 * <p>
 * The passband ripple percentage is how much "ripple" there is in the passband. The thing to know is that 
 * a higher ripple percentage results in a faster transition between the passband and the stopband. However, 
 * large ripple can distort the signal somewhat.
 * <p>
 * The number of poles refer to the poles of an IIR, or recursive, digital filter. The thing to know is 
 * that a larger number of poles usually makes for a better filter. The ChebFilter has some limitations 
 * on the number of poles used. The number of poles must be even and between 2 and 20.
 * The filter will report an error if either of those conditions are not met. However, it should also be 
 * mentioned that depending on the current cutoff frequency of the filter, the 
 * number of poles that will result in a <i>stable</i> filter, can be as few as 4.
 * The filter will not report an error in the case of the number of requested 
 * poles resulting in an unstable filter. Generally, you probably won't need to use more than 6 poles. 
 * For reference, here is a table of the maximum number of poles possible according to cutoff frequency:
 * <p>
 * <table>
 *   <tr>
 *     <td>Cutoff Frequency<br />(expressed as a fraction of the sampling rate)</td>
 *     <td>0.02</td>
 *     <td>0.05</td>
 *     <td>0.10</td>
 *     <td>0.25</td>
 *     <td>0.40</td>
 *     <td>0.45</td>
 *     <td>0.48</td>
 *   </tr>
 *   <tr>
 *     <td>Maximum poles</td>
 *     <td>4</td>
 *     <td>6</td>
 *     <td>10</td>
 *     <td>20</td>
 *     <td>10</td>
 *     <td>6</td>
 *     <td>4</td>
 *   </tr>
 * </table> 
 */

import controlP5.*;
import ddf.minim.*;
import ddf.minim.effects.*;

Minim minim;
AudioPlayer groove;
ChebFilter cbf;
ControlP5 gui;

public int cutoffFreq = 4410;
public float ripplePercent = 2;

void setup()
{
  size(512, 512, P3D);
  textMode(SCREEN);
  minim = new Minim(this);
  groove = minim.loadFile("groove.mp3");
  groove.loop();
  // make a two pole low pass filter with a cutoff frequency of 4410 Hz and a ripple percentages of 2%
  // the final argument is the sample rate of audio that will be filetered
  // it is required to correctly compute values used by the filter
  cbf = new ChebFilter(cutoffFreq, ChebFilter.LP, ripplePercent, 2, groove.sampleRate());
  cbf.printCoeff();
  groove.addEffect(cbf);
  
  gui = new ControlP5(this);
  gui.addSlider("cutoffFreq", 200, 21000, cutoffFreq, width/6, 300, 10, 100);
  gui.addSlider("ripplePercent", 0, 20, ripplePercent, 2*width/6, 300, 10, 100);
  Radio r = gui.addRadio("poles", 4*width/6, 300);
  r.setId(1);
  r.add("two", 0);
  r.add("four", 1);
  r.add("six", 2);
  r.add("eight", 3);
  r.add("ten", 4);
  r.add("twelve", 5);
  r.add("fourteen", 6);
  r.add("sixteen", 7);
  r.add("eighteen", 8);
  r.add("twenty", 9);
  r = gui.addRadio("type", 5*width/6, 300);
  r.setId(2);
  r.add("low pass", 1);
  r.add("high pass", 2);
}

void draw()
{
  if ( cbf.frequency() != cutoffFreq ) cbf.setFreq(cutoffFreq);
  if ( cbf.getRipple() != ripplePercent ) cbf.setRipple(ripplePercent);
  
  background(0);
  gui.draw();
  stroke(255);
  // draw the waveforms
  // the values returned by left.get() and right.get() will be between -1 and 1,
  // so we need to scale them up to see the waveform
  for(int i = 0; i < groove.bufferSize() - 1; i++)
  {
    float x1 = map(i, 0, groove.bufferSize(), 0, width);
    float x2 = map(i+1, 0, groove.bufferSize(), 0, width);
    line(x1, 50 - groove.left.get(i)*50, x2, 50 - groove.left.get(i+1)*50);
    line(x1, 150 - groove.right.get(i)*50, x2, 150 - groove.right.get(i+1)*50);
  }
}

void poles(int n)
{
  int p = (n+1)*2;
  println("New num poles: " + p);
  if ( p != cbf.getPoles() ) cbf.setPoles(p);
}

public void controlEvent(ControlEvent theEvent) 
{
  if ( theEvent.controller().id() == 1 )
  {
    poles((int)theEvent.controller().value());
  }
  if ( theEvent.controller().id() == 2 )
  {
    cbf.setType((int)theEvent.controller().value());
  }
}

void stop()
{
  // always closes Minim audio classes when you are finished with them
  groove.close();
  // always stop Minim before exiting
  minim.stop();
  super.stop();
}
