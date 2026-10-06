# Cancer Care Navigator

A local app that helps people with cancer find care that fits their insurance and location, keeps out-of-pocket costs in mind, and points to current treatments and clinical trials for their disease status.

You describe your situation in your own words. The app turns it into an organized disease summary and lists next-step options (NCCN guideline care, emerging evidence from ASCO/ESMO, recruiting clinical trials, and your own doctor's recommendations). It then finds oncologists near you who can provide those options and shows them on a map.

> **For information and planning only. This is not medical advice.** Review every option with your oncologist before making treatment decisions.

## Quick start

**You need:** a recent version of Chrome, Edge, Firefox or Safari; an internet connection; and an [Anthropic API key](https://console.anthropic.com/settings/keys).

**Windows**

1. Download or clone this repository.
2. Double-click **`Start Cancer Care Navigator.bat`**.
3. Your browser opens the app at `http://localhost:8765`. Keep the black launcher window open while you use the app; close it to stop.

**macOS / Linux** (needs Python 3)

```bash
sh start.sh
```

Then open `http://localhost:8765/cancer_care_navigator.html` if it doesn't open by itself. Press Ctrl+C to stop.

**First run:** click **API key** at the top right, paste your Anthropic API key, and click **Save**. Tick "Remember on this computer" if you don't want to paste it each time.

> Opening `cancer_care_navigator.html` directly from the folder (a `file://` address) does not work, because browsers block the app's code modules there. Always use the launcher.

## How to use it

| Step | What you do | What the app does |
|---|---|---|
| 1. Insurance | Enter primary and, if you have one, secondary insurance (company, plan type, plan name). | Uses it to check whether each oncologist or cancer center appears to accept your coverage. No member ID is needed. |
| 2. Location | Enter a home address, or just a city, ZIP code or state, and how far you'll travel. | Shows the place and your travel radius on a map. |
| 3. Disease status | Describe your diagnosis, stage, treatments so far, biomarkers, symptoms, other conditions and side effects. **Load an example** fills in a sample. | Claude organizes it into a structured summary and lists details your oncologist would want that you didn't mention. |
| 4. Doctor's next steps | Optional: tests, procedures or treatments your doctor recommended, one per line. | Includes them in the options. If left blank, the app suggests next steps itself. |
| 5. Care options | Click **Find care options** (1–3 minutes). | Searches recruiting trials near you on ClinicalTrials.gov and recent PubMed research, then has Claude review NCCN guidelines and ASCO/ESMO evidence. Shows a table of options with their source (NCCN, emerging evidence, clinical trial, or your doctor), the top 3 matching trials, and questions to ask your oncologist. |
| 6. Oncologists | Click **Find matching oncologists** (2–4 minutes). | Finds oncologists or teams who can provide your options, checks their publications and trials, and maps them. Hover a pin to highlight the options that oncologist can provide and get a link to their webpage. The side panel shows specialty, experience, institution, research activity, distance and insurance status. |

## Where the information comes from

| Source | Used for | How |
|---|---|---|
| Claude (`claude-opus-5-5`) with web search | Organizing your description; NCCN and ASCO/ESMO review; finding and assessing oncologists; insurance checks | Anthropic Messages API, called from your browser with your key |
| [ClinicalTrials.gov API v2](https://clinicaltrials.gov/data-api/api) | Recruiting trials near you; trials each oncologist leads | Live, no key needed |
| [PubMed E-utilities](https://www.ncbi.nlm.nih.gov/books/NBK25501/) | Recent research; each oncologist's publications | Live, no key needed |
| [OpenStreetMap Nominatim](https://nominatim.org/) (Photon as backup) | Turning addresses into map locations | Live, no key needed |
| Esri World Street Map | Map tiles | Live, no key needed |

Requests to Claude turn on Anthropic's server-side fallback (`fallbacks: "default"`), so a request Claude declines is retried on another model automatically.

## Privacy

- Everything runs in your browser. The launcher only serves the app's files to your own computer (`localhost`); nothing is uploaded to a server of this project.
- What you type is sent only to the services above, and only for the step you run: your disease description and insurance go to Anthropic; search terms (cancer type, biomarkers, oncologist names) go to ClinicalTrials.gov and PubMed; addresses go to the map lookup service.
- The app doesn't save your health information. It disappears when you close the tab.
- Your API key stays in the browser tab, or in the browser's local storage if you tick "Remember on this computer". Untick it and click **Save** to remove it.

## Cost

Each full run (steps 3, 5 and 6) makes three Claude requests, two of which use web search. The cost depends on how much Claude reads; check your usage at [console.anthropic.com](https://console.anthropic.com/). ClinicalTrials.gov, PubMed and the map services are free.

## Limitations

- **NCCN guidelines** need a login, so NCCN items come from public summaries Claude finds by web search. Confirm them with your oncologist.
- **Insurance acceptance** is marked "accepted" only when Claude finds a source. Anything else is flagged. Always confirm with the office and your insurer.
- **PubMed counts** match by author name, so common names can include other people's papers.
- **Oncologist details** (experience, address, phone) come from public webpages and may be out of date.
- Trial eligibility is a first look only. The trial team decides who can enroll.

## Project layout

```
cancer_care_navigator.html        The app (HTML, CSS and JavaScript in one file)
Start Cancer Care Navigator.bat   Windows launcher
server.ps1                        Local web server the Windows launcher runs (localhost only)
start.sh                          macOS / Linux launcher (Python 3)
vendor/                           Libraries bundled so the app doesn't load code from the internet
  anthropic-sdk/                  @anthropic-ai/sdk 0.131.0 (browser ES module build)
  leaflet/                        Leaflet 1.9.4 (maps)
  tabler-icons/                   Tabler Icons webfont 3.31.0
```

The libraries in `vendor/` keep their own licenses (see the `LICENSE` file in each folder).
